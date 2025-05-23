const express = require('express');
const { Sequelize } = require('sequelize');
const axios = require('axios');
const Post = require('./models/post');

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
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

// Главная страница — список постов
app.get('/', async (req, res) => {
  const posts = await Post.findAll({ order: [['createdAt', 'DESC']] });
  res.render('index', { posts });
});

// Просмотр отдельного поста
app.get('/post/:id', async (req, res) => {
  const post = await Post.findByPk(req.params.id);
  res.render('post', { post });
});

// Страница создания поста
app.get('/new', (req, res) => {
  res.render('new');
});

// Обработка формы создания поста
app.post('/new', async (req, res) => {
  const { title, content } = req.body;

  // Сохраняем в базу
  const post = await Post.create({ title, content });

  // Вызов AWS Lambda через API Gateway
  try {
    await axios.post('https://ug9ep40cs3.execute-api.eu-north-1.amazonaws.com/default/send_notification', {
      id: post.id,
      title: post.title,
      content: post.content,
      createdAt: post.createdAt
    });
    console.log('✅ Lambda вызвана успешно');
  } catch (error) {
    console.error('❌ Ошибка вызова Lambda:', error.message);
  }

  res.redirect('/');
});

// Запуск сервера
sequelize.sync().then(() => {
  app.listen(PORT, () => console.log(`Server running on http://172.31.41.175`));
});
