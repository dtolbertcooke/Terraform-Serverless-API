const express = require("express");
const joi = require("joi"); // input validation
const { DynamoDBClient } = require("@aws-sdk/client-dynamodb");
const {
  DynamoDBDocumentClient,
  UpdateCommand,
} = require("@aws-sdk/lib-dynamodb");

const client = new DynamoDBClient({});
const dynamo = DynamoDBDocumentClient.from(client);
const tableName = process.env.DYNAMODB_TABLE;
const app = express();
app.use(express.json());

// schema for PATCH input validation
const updateFruitSchema = joi
  .object({
    name: joi.string().min(1).max(20).optional(), // optional, but must be valid if present
    price: joi.number().positive().precision(2).optional(), // optional, must be > 0
    id: joi.forbidden(), // forbid user from updating id
  })
  .or("name", "price"); // require at least one field

app.patch("/fruits/:id", async (req, res) => {
  const { id } = req.params;

  // Validate input
  const { error, value } = updateFruitSchema.validate(req.body, {
    abortEarly: false, // collect all errors
    allowUnknown: false, // reject extra fields
  });

  if (error) {
    return res.status(400).json({
      error: "Invalid input",
      details: error.details.map((d) => d.message),
    });
  }

  try {
    const updateExpressionParts = [];
    const expressionAttributeNames = {};
    const expressionAttributeValues = {};

    if (value.price !== undefined) {
      updateExpressionParts.push("#price = :price");
      expressionAttributeNames["#price"] = "price";
      expressionAttributeValues[":price"] = value.price;
    }
    if (value.name !== undefined) {
      updateExpressionParts.push("#name = :name");
      expressionAttributeNames["#name"] = "name";
      expressionAttributeValues[":name"] = value.name;
    }

    const updateExpression = `SET ${updateExpressionParts.join(", ")}`;

    const result = await dynamo.send(
      new UpdateCommand({
        TableName: tableName,
        Key: { id },
        UpdateExpression: updateExpression,
        ExpressionAttributeNames: expressionAttributeNames,
        ExpressionAttributeValues: expressionAttributeValues,
        ReturnValues: "ALL_NEW",
      })
    );

    res
      .status(200)
      .json({ message: "Fruit updated", updatedItem: result.Attributes });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

module.exports = app;
