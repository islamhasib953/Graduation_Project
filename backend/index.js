const mongoose = require('mongoose')
const app = require('./app')


process.on('uncaughtException', (err) => {
  console.error('⛔ ' + err.name, err.message, err.stack)
  process.exit(1)
})

const DBLink = process.env.DATA_BASE_URL.replace('<DATABASENAME>', process.env.DATA_BASE_NAME).replace('<PASSWORD>', process.env.DATA_BASE_PASSWORD)
const port = process.env.PORT || 8000
mongoose.set('strictQuery', false);
mongoose.connect(DBLink).then(() => console.log('✅ connect with DataBase'))
const server = app.listen(port, () => console.log(`✅ app listening on port ${port}`))

process.on('unhandledRejection', (err) => {
  console.error('🚨 ' + err.name, err.message)
  server.close(() => process.exit(1))
})
