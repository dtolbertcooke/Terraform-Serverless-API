process.env.DYNAMODB_TABLE = "test-table"; // DYNAMODB_TABLE is a needed env var in my lambda code
const { mockClient } = require("aws-sdk-client-mock");
const { DynamoDBDocumentClient, PutCommand } = require("@aws-sdk/lib-dynamodb");
const dynamoDBDocClientMock = mockClient(DynamoDBDocumentClient);

const request = require("supertest");
const app = require("../handlers/fruit-api-PUT/app");

beforeEach(() => {
  dynamoDBDocClientMock.reset();
});

describe("PUT /fruits", () => {
  // success case - hits dynamodb
  it("should create a fruit when valid input is provided", async () => {
    dynamoDBDocClientMock.on(PutCommand).resolves({}); // mock successful connection to dynamodb table

    const response = await request(app)
      .put("/fruits")
      .send({ id: "100", name: "Apple", price: 2.5 });

    expect(response.statusCode).toBe(201);
    expect(response.body.message).toBe("Added fruit: Apple");
  });

  // validation case - missing fields - no hits to table so no dynamoDBDocClientMock.on(PutCommand)...
  it("should return 400 if required fields are missing", async () => {
    const response = await request(app).put("/fruits").send({ id: "100" });

    expect(response.statusCode).toBe(400);
    expect(response.body.message).toBe("Validation failed");
    // expect(response.body).toHaveProperty("message", "Validation failed");
  });

  // validation case - negative price - no hits to table so no dynamoDBDocClientMock.on(PutCommand)...
  it("should return 400 if price is negative", async () => {
    const response = await request(app)
      .put("/fruits")
      .send({ id: "101", name: "Orange", price: -5.2 });

    expect(response.statusCode).toBe(400);
    expect(response.body.message).toBe("Validation failed");
  });

  // DynamoDB failure case - hits table but fails
  it("should return 500 if DynamoDB fails", async () => {
    dynamoDBDocClientMock.on(PutCommand).rejects(new Error("DynamoDB error")); // mock failure connection to dynamodb table

    const response = await request(app)
      .put("/fruits")
      .send({ id: "101", name: "Banana", price: 1.5 });

    expect(response.statusCode).toBe(500);
    expect(response.body).toHaveProperty("error", "DynamoDB error");
  });
});
