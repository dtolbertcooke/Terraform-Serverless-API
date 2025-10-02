const express = require("express");
const joi = require("joi");
const { DynamoDBClient } = require("@aws-sdk/client-dynamodb");
const { DynamoDBDocumentClient, PutCommand } = require("@aws-sdk/lib-dynamodb");

const client = new DynamoDBClient({});
const dynamo = DynamoDBDocumentClient.from(client);
const tableName = process.env.DYNAMODB_TABLE;
const app = express();
app.use(express.json());

// schema for input validation
const fruitSchema = joi.object({
  id: joi.string().pattern(/^\d+$/).required(),
  name: joi.string().required(),
  price: joi.number().positive().required(),
});

app.put("/fruits", async (req, res) => {
  const { error, value } = fruitSchema.validate(req.body, {
    abortEarly: false,
  });

  if (error) {
    return res.status(400).json({
      message: "Validation failed",
      details: error.details.map((d) => d.message),
    });
  }

  const { id, name, price } = value;

  try {
    await dynamo.send(
      new PutCommand({
        TableName: tableName,
        Item: { id, price, name },
      })
    );
    res.status(201).json({ message: `Added fruit: ${name}` });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

module.exports = app;
