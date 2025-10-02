process.env.DYNAMODB_TABLE = "test-table"; // DYNAMODB_TABLE is a needed env var in my lambda code
const { mockClient } = require("aws-sdk-client-mock");
const {
  DynamoDBDocumentClient,
  UpdateCommand,
} = require("@aws-sdk/lib-dynamodb");
const dynamoDBDocClientMock = mockClient(DynamoDBDocumentClient);

const request = require("supertest");
const app = require("../handlers/fruit-api-PATCH/app");

beforeEach(() => {
  dynamoDBDocClientMock.reset();
});

describe("PATCH /fruits/:id", () => {
  it("should update a fruit when valid id and data are provided", async () => {
    dynamoDBDocClientMock.on(UpdateCommand).resolves({});

    const response = await request(app)
      .patch("/fruits/100")
      .send({ name: "Apple", price: 2.5 });

    expect(response.statusCode).toBe(200);
  });

  it("should return 400 if id is invalid", async () => {
    const response = await request(app).patch("/fruits/abc");

    expect(response.statusCode).toBe(400);
    expect(response.body.error).toBe("Invalid input");
  });

  it("should return 500 if DynamoDB update fails", async () => {
    dynamoDBDocClientMock
      .on(UpdateCommand)
      .rejects(new Error("DynamoDB error"));

    const response = await request(app)
      .patch("/fruits/100")
      .send({ name: "Apple" });

    expect(response.statusCode).toBe(500);
    expect(response.body).toHaveProperty("error", "DynamoDB error");
  });
});
