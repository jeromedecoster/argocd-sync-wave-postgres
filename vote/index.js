const nunjucks = require('nunjucks')
const express = require('express')
const { Client } = require('pg')
const axios = require('axios')

for (var name of ['NODE_ENV', 'VERSION', 'WEBSITE_PORT', 'POSTGRES_USER', 'POSTGRES_HOST', 'POSTGRES_DATABASE', 'POSTGRES_PASSWORD', 'POSTGRES_PORT']) {
    if (process.env[name] == null || process.env[name].length == 0) { 
        throw new Error(`${name} environment variable is required`)
    }
    console.log(`process.env.${name}: ${process.env[name]}`)
}

const NODE_ENV = process.env.NODE_ENV
const VERSION = process.env.VERSION
const WEBSITE_PORT = process.env.WEBSITE_PORT
const POSTGRES_USER = process.env.POSTGRES_USER
const POSTGRES_HOST = process.env.POSTGRES_HOST
const POSTGRES_DATABASE = process.env.POSTGRES_DATABASE
const POSTGRES_PASSWORD = process.env.POSTGRES_PASSWORD
const POSTGRES_PORT = process.env.POSTGRES_PORT

const app = express()

app.use(express.static('public'))
app.use(express.json())

nunjucks.configure('views', {
    express: app,
    autoescape: false,
    noCache: true
})

app.set('view engine', 'njk')

app.locals.node_env = NODE_ENV
app.locals.version = VERSION

if (NODE_ENV == 'development') {
    const livereload = require('connect-livereload')
    app.use(livereload())
}

const client = new Client({
    user: POSTGRES_USER,
    host: POSTGRES_HOST,
    database: POSTGRES_DATABASE,
    password: POSTGRES_PASSWORD,
    port: POSTGRES_PORT,
})

console.log('client.connect')
client.connect()

app.get('/', async (req, res) => {
    try {
        res.render('index')
        
    } catch (err) {
        return res.json({
            code: err.code, 
            message: err.message
        })
    }
})

/*
    curl http://localhost:3000/vote
*/
app.get('/vote', async (req, res) => {
    let up = await client.query("SELECT value FROM vote WHERE name = 'up'")
    // console.log('up:', up)
    up = Number(up.rows[0].value)
    let down = await client.query("SELECT value FROM vote WHERE name = 'down'")
    down = Number(down.rows[0].value)
    return res.send({ up, down })
})

/*
    curl http://localhost:3000/vote \
        --header 'Content-Type: application/json' \
        --data '{"vote":"up"}'
*/
app.post('/vote', async (req, res) => {
    try {
        console.log('POST /vote: %j', req.body)
        // console.log(req.body.vote)
        let result = await client.query(`UPDATE vote SET value = value + 1 WHERE name = '${req.body.vote}'`)
        // console.log('result:', result)
        return res.send({ success: true, result: 'hello' })
        
    } catch (err) {
        console.log('ERROR: POST /vote: %s', err.message || err.response || err);
        res.status(500).send({ success: false, reason: 'internal error' });
    }
})

app.listen(WEBSITE_PORT, () => {
    console.log(`listening on port ${WEBSITE_PORT}`)
})
