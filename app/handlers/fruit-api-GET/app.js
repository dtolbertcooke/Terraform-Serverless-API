const express = require("express");
const joi = require("joi");
const { DynamoDBClient } = require("@aws-sdk/client-dynamodb");
const {
  DynamoDBDocumentClient,
  GetCommand,
  ScanCommand,
} = require("@aws-sdk/lib-dynamodb");

const client = new DynamoDBClient({});
const dynamo = DynamoDBDocumentClient.from(client);
const tableName = process.env.DYNAMODB_TABLE;
const app = express();
app.use(express.json());

// schema for GET validation
const idSchema = joi.object({
  id: joi.string().pattern(/^\d+$/).required(),
});

app.get("/fruits", async (req, res) => {
  try {
    const result = await dynamo.send(
      new ScanCommand({
        TableName: tableName,
      })
    );
    res.status(200).json(result.Items);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.get("/fruits/:id", async (req, res) => {
  // If id param is missing or empty, return 400
  if (!req.params.id) {
    return res.status(400).json({ error: "missing id" });
  }

  const { error, value } = idSchema.validate(req.params);
  if (error) {
    return res.status(400).json({
      error: "Invalid ID",
      details: error.details.map((d) => d.message),
    });
  }

  try {
    const result = await dynamo.send(
      new GetCommand({
        TableName: tableName,
        Key: { id: value.id },
      })
    );
    res.status(200).json(result.Item);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

module.exports = app;
