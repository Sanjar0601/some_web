const { DataTypes, Model } = require('sequelize');

class Post extends Model {
  static initModel(sequelize) {
    Post.init({
      title: {
        type: DataTypes.STRING,
        allowNull: false
      },
      content: {
        type: DataTypes.TEXT,
        allowNull: false
      }
    }, {
      sequelize,
      modelName: 'Post',
      timestamps: true
    });
  }
}

module.exports = Post;
