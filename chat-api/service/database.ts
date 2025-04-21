import mysql from 'mysql2';

const databasePool = mysql.createPool({
    host : process.env.DB_HOST,
    user : process.env.DB_USERNAME,
    password : process.env.DB_PASSWORD,
    database : process.env.DB_DATABASE,
    waitForConnections: true,
}).promise()



databasePool.getConnection().then(() => console.log("Succesfuly connected")).catch(e => console.log(e))

export default databasePool