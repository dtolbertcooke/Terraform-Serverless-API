process.env.DYNAMODB_TABLE = "test-table"; // DYNAMODB_TABLE is a needed env var in my lambda code
const { mockClient } = require("aws-sdk-client-mock");
const {
  DynamoDBDocumentClient,
  GetCommand,
  ScanCommand,
} = require("@aws-sdk/lib-dynamodb");
const dynamoDBDocClientMock = mockClient(DynamoDBDocumentClient);

const request = require("supertest");
const app = require("../handlers/fruit-api-GET/app");

beforeEach(() => {
  dynamoDBDocClientMock.reset();
});

// get all fruits
describe("GET /fruits", () => {
  // success case - hits dynamodb
  it("should get all fruits", async () => {
    dynamoDBDocClientMock.on(ScanCommand).resolves({
      Items: [
        { id: "100", name: "Apple", price: 2.5 },
        { id: "101", name: "Banana", price: 1.5 },
      ],
    }); // mock successful connection to dynamodb table with dummy table values

    const response = await request(app).get("/fruits");
    expect(response.statusCode).toBe(200); // 200 is standard for GET
    expect(response.body).toEqual([
      { id: "100", name: "Apple", price: 2.5 },
      { id: "101", name: "Banana", price: 1.5 },
    ]);
  });

  it("should return 500 if DynamoDB scan fails", async () => {
    dynamoDBDocClientMock.on(ScanCommand).rejects(new Error("DynamoDB error"));

    const response = await request(app).get("/fruits");

    expect(response.statusCode).toBe(500);
    expect(response.body).toHaveProperty("error", "DynamoDB error");
  });
});

describe("GET /fruits/:id", () => {
  it("should return a single fruit when valid id is provided", async () => {
    dynamoDBDocClientMock.on(GetCommand).resolves({
      Item: { id: "100", name: "Apple", price: 2.5 },
    });

    const response = await request(app).get("/fruits/100");

    expect(response.statusCode).toBe(200);
    expect(response.body).toEqual({ id: "100", name: "Apple", price: 2.5 });
  });

  it("should return 400 if id is invalid", async () => {
    const response = await request(app).get("/fruits/abc"); // invalid id test

    expect(response.statusCode).toBe(400);
    expect(response.body.error).toBe("Invalid ID");
  });

  it("should return 500 if DynamoDB get fails", async () => {
    dynamoDBDocClientMock.on(GetCommand).rejects(new Error("DynamoDB error"));

    const response = await request(app).get("/fruits/100");

    expect(response.statusCode).toBe(500);
    expect(response.body).toHaveProperty("error", "DynamoDB error");
  });
});
