const express = require("express");
const router = express.Router();
// const childController = require("../controllers/childController");
const verifyToken = require("../middlewares/virifyToken");
const checkOwnership = require("../middlewares/Ownership");
const { validationSchema } = require("../middlewares/validationschema");
const childController =require("../controllers/child.controller");

router
  .route("/")
  .get(verifyToken, checkOwnership, childController.getAllChildren)
  .post(verifyToken, checkOwnership, childController.createChild);


router.route("/:childId")
  .get(verifyToken, checkOwnership, childController.getSingleChild)
  .patch(verifyToken, checkOwnership, childController.updateChild)
  .delete(verifyToken, checkOwnership, childController.deleteChild);

module.exports = router;
