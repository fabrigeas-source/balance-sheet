const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');


const path = require('path');
const app = express();
const port = 3000;

app.use(cors());
app.use(bodyParser.json());

// Serve static files from 'public' directory
const staticDir = path.join(__dirname, 'public');
app.use(express.static(staticDir));

// In-memory data store
let entries = [];
let nextId = 1;

// Get all entries
app.get('/api/entries', (req, res) => {
  res.json(entries);
});

// Add a new entry
app.post('/api/entries', (req, res) => {
  const { title, amount } = req.body;
  if (!title || typeof amount !== 'number') {
    return res.status(400).json({ error: 'Invalid entry data' });
  }
  const entry = { id: nextId++, title, amount };
  entries.push(entry);
  res.status(201).json(entry);
});

// Delete an entry
app.delete('/api/entries/:id', (req, res) => {
  const id = parseInt(req.params.id, 10);
  const index = entries.findIndex(e => e.id === id);
  if (index === -1) {
    return res.status(404).json({ error: 'Entry not found' });
  }
  entries.splice(index, 1);
  res.status(204).send();
});


// SPA fallback: serve index.html for all unmatched GET requests
app.get('*', (req, res) => {
  res.sendFile(path.join(staticDir, 'index.html'));
});

app.listen(port, () => {
  console.log(`Balance Sheet backend listening at http://localhost:${port}`);
});
