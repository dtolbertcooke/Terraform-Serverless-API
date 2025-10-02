process.env.DYNAMODB_TABLE = "test-table"; // DYNAMODB_TABLE is a needed env var in my lambda code
const { mockClient } = require("aws-sdk-client-mock");
const {
  DynamoDBDocumentClient,
  DeleteCommand,
} = require("@aws-sdk/lib-dynamodb");
const dynamoDBDocClientMock = mockClient(DynamoDBDocumentClient);

const request = require("supertest");
const app = require("../handlers/fruit-api-DELETE/app");

beforeEach(() => {
  dynamoDBDocClientMock.reset();
});

describe("DELETE /fruits/:id", () => {
  it("should delete a fruit when valid id is provided", async () => {
    dynamoDBDocClientMock.on(DeleteCommand).resolves({});

    const response = await request(app).delete("/fruits/100");

    expect(response.statusCode).toBe(200);
  });

  it("should return 400 if id is invalid", async () => {
    const response = await request(app).delete("/fruits/abc");

    expect(response.statusCode).toBe(400);
    expect(response.body.error).toBe("Invalid ID");
  });

  it("should return 500 if DynamoDB delete fails", async () => {
    dynamoDBDocClientMock
      .on(DeleteCommand)
      .rejects(new Error("DynamoDB error"));

    const response = await request(app).delete("/fruits/100");

    expect(response.statusCode).toBe(500);
    expect(response.body).toHaveProperty("error", "DynamoDB error");
  });
});
