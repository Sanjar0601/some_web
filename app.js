const express = require('express');
const { Sequelize } = require('sequelize');
const Post = require('./models/post');

const app = express();
const PORT = process.env.PORT || 3000;

app.use(express.urlencoded({ extended: true }));
app.use(express.static('public'));
app.set('view engine', 'ejs');

// DB init
const sequelize = new Sequelize({
  dialect: 'sqlite',
  storage: 'blog.sqlite'
});

Post.initModel(sequelize);

// Routes
app.get('/', async (req, res) => {
  const posts = await Post.findAll({ order: [['createdAt', 'DESC']] });
  res.render('index', { posts });
});

app.get('/post/:id', async (req, res) => {
  const post = await Post.findByPk(req.params.id);
  res.render('post', { post });
});

app.get('/new', (req, res) => {
  res.render('new');
});

app.post('/new', async (req, res) => {
  const { title, content } = req.body;
  await Post.create({ title, content });
  res.redirect('/');
});

// Start
sequelize.sync().then(() => {
  app.listen(PORT, () => console.log(`Server running on http://localhost:${PORT}`));
});
