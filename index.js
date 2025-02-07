// Import Mongoose, Express, and dotenv
require('dotenv').config();
const mongoose = require('mongoose');
const express = require('express');
const cors = require('cors');
const router = express.Router();

// MongoDB Connection URI from .env file
const mongoURI = process.env.MONGO_URI;

// Connect to MongoDB
mongoose.connect(mongoURI)
    .then(() => console.log('✅ Connected to MongoDB successfully!'))
    .catch((err) => {
        console.error('❌ MongoDB Connection Error:', err.message);
        console.error('Stack:', err.stack);
    });

// Create an Express server
const app = express();
const PORT = process.env.PORT || 5000;

app.use(cors({ origin: "*" }));
app.use(express.urlencoded({ extended: true }));
app.use(express.json());

// Task Schema
const taskSchema = new mongoose.Schema({
    title: { type: String, required: true },
    category: { type: String, default: 'General' },
    priority: { type: String, required: true, default: 'FFFFFF' },
    isCompleted: { type: Boolean, default: false },
    dueDate: { type: Date, default: null },
    notes: { type: String, default: '' },
    subtasks: { type: [String], default: [] },
    isStarred: { type: Boolean, default: false },
    createdAt: { type: Date, default: Date.now }
});

const Task = mongoose.model('Task', taskSchema);

// Routes
app.get('/', (req, res) => {
    res.send('🚀 Server is running and connected to MongoDB!');
});

router.get('/tasks', async (req, res) => {
    try {
        const tasks = await Task.find() || [];
        res.json(tasks);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
});

router.post('/tasks', async (req, res) => {
    try {
        const { title, category, priority, isCompleted, dueDate, notes, subtasks, isStarred } = req.body;

        if (!title || !priority) {
            return res.status(400).json({ message: 'Title and priority are required fields.' });
        }

        const task = new Task({
            title,
            category: category || 'General',
            priority,
            isCompleted: isCompleted ?? false,
            dueDate: dueDate ? new Date(dueDate) : null,
            notes: notes || '',
            subtasks: Array.isArray(subtasks) ? subtasks : [],
            isStarred: isStarred ?? false
        });

        const newTask = await task.save();
        res.status(201).json(newTask);
    } catch (error) {
        console.error('Error creating task:', error);
        res.status(500).json({ message: error.message });
    }
});

router.patch('/tasks/:id', async (req, res) => {
    try {
        const task = await Task.findById(req.params.id);
        if (!task) {
            return res.status(404).json({ message: 'Task not found' });
        }

        Object.keys(req.body).forEach(key => {
            if (key in task && req.body[key] !== undefined) {
                task[key] = req.body[key];
            }
        });

        const updatedTask = await task.save();
        res.json(updatedTask);
    } catch (error) {
        res.status(400).json({ message: error.message });
    }
});

router.delete('/tasks/:id', async (req, res) => {
    try {
        const task = await Task.findById(req.params.id);
        if (!task) {
            return res.status(404).json({ message: 'Task not found' });
        }
        await task.deleteOne();
        res.json({ message: 'Task deleted' });
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
});

// Apply API routes
app.use('/api', router);

// Global error handler
app.use((err, req, res, next) => {
    console.error(err.stack);
    res.status(500).json({ message: 'Something went wrong!' });
});

// Start the server
app.listen(PORT, () => {
    console.log(`🚀 Server running on http://localhost:${PORT}`);
});
