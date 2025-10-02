const express = require("express");
const joi = require("joi");
const { DynamoDBClient } = require("@aws-sdk/client-dynamodb");
const {
  DynamoDBDocumentClient,
  DeleteCommand,
} = require("@aws-sdk/lib-dynamodb");

const client = new DynamoDBClient({});
const dynamo = DynamoDBDocumentClient.from(client);
const tableName = process.env.DYNAMODB_TABLE;
const app = express();
app.use(express.json());

// schema for DELETE validation
const idSchema = joi.object({
  id: joi.string().pattern(/^\d+$/).required(),
});

app.delete("/fruits/:id", async (req, res) => {
  // Validate path parameter
  const { error, value } = idSchema.validate(req.params);

  if (error) {
    return res.status(400).json({
      error: "Invalid ID",
      details: error.details.map((d) => d.message),
    });
  }

  try {
    await dynamo.send(
      new DeleteCommand({
        TableName: tableName,
        Key: { id: value.id },
      })
    );
    res.status(200).json({ message: `Deleted fruit with id: ${value.id}` });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

module.exports = app;
