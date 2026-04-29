// =============================
// CATALOGUE DB
// =============================
db = db.getSiblingDB('catalogue');

if (db.products.countDocuments() === 0) {
  db.products.insertMany([
    {
      sku: "ABC123",
      name: "Robot Arm",
      price: 100,
      instock: 10
    },
    {
      sku: "XYZ789",
      name: "Robot Head",
      price: 50,
      instock: 5
    },
    {
      sku: "LMN456",
      name: "Robot Wheel",
      price: 25,
      instock: 20
    }
  ]);
  print("Catalogue seeded");
} else {
  print("Catalogue already initialized");
}

// =============================
// USER DB
// =============================
db = db.getSiblingDB('user');

if (db.users.countDocuments() === 0) {
  db.users.insertOne({
    username: "user",
    password: "password"
  });
  print("User seeded");
} else {
  print("User DB already initialized");
}