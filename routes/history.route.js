const express = require("express");
const router = express.Router();
const verifyToken = require("../middlewares/virifyToken");
const checkOwnership = require("../middlewares/Ownership");
const { validationSchema } = require("../middlewares/validationschema");
const historyController = require("../controllers/history.controller");
const allowedTo = require('../middlewares/allowedTo');
const userRoles = require('../utils/userRoles');

router
  .route("/:childId")
  .get(
    verifyToken,
    allowedTo(userRoles.ADMIN, userRoles.DOCTOR, userRoles.PATIENT),
    historyController.getAllHistory
  )
  .post(
    verifyToken,
    allowedTo(userRoles.ADMIN, userRoles.DOCTOR),
    historyController.createHistory
  );

router
  .route("/:childId/:historyId")
  .get(
    verifyToken,
    allowedTo(userRoles.ADMIN, userRoles.DOCTOR, userRoles.PATIENT),
    historyController.getSingleHistory
  )
  .patch(verifyToken, checkOwnership, historyController.updateHistory)
  .delete(
    verifyToken,
    allowedTo(userRoles.ADMIN, userRoles.DOCTOR),
    historyController.deleteHistory
  );

  router
    .route("/filter/:childId")
    .get(
      verifyToken,
      allowedTo(userRoles.ADMIN, userRoles.DOCTOR, userRoles.PATIENT),
      historyController.filterHistory
    );


module.exports = router;
