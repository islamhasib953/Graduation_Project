// const mongoose = require("mongoose");
// const http = require("http");
// const app = require("./app");

// process.on("uncaughtException", (err) => {
//   console.error("⛔ " + err.name, err.message, err.stack);
//   process.exit(1);
// });

// const port = process.env.PORT || 8000;

// const server = http.createServer(app);
// server.listen(port, () => console.log(`✅ app listening on port ${port}`));

// process.on("unhandledRejection", (err) => {
//   console.error("🚨 " + err.name, err.message);
//   server.close(() => process.exit(1));
// });



const mongoose = require("mongoose");
const { app, server } = require("./app");

process.on("uncaughtException", (err) => {
  console.error("⛔ " + err.name, err.message, err.stack);
  process.exit(1);
});

const port = process.env.PORT || 8000;

server.listen(port, () => console.log(`✅ app listening on port ${port}`));

process.on("unhandledRejection", (err) => {
  console.error("🚨 " + err.name, err.message);
  server.close(() => process.exit(1));
});