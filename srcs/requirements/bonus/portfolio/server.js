const express = require('express');
const path = require('path');
const app = express();
const PORT = 3000;

// Serve static files
app.use(express.static(path.join(__dirname, 'public')));

// Main route
app.get('/', (req, res) => {
    res.sendFile(path.join(__dirname, 'public', 'index.html'));
});

// API route for portfolio data
app.get('/api/info', (req, res) => {
    res.json({
        name: 'Matteo Jeannin',
        title: '42 Student - System Administration',
        project: 'Inception Docker Infrastructure',
        skills: ['Docker', 'System Administration', 'Web Development', 'Linux'],
        description: 'Passionate about containerization and infrastructure automation.'
    });
});

app.listen(PORT, '0.0.0.0', () => {
    console.log(`Portfolio server running on port ${PORT}`);
});