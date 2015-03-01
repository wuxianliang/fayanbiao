
Students  = new Mongo.Collection('students');
Lessons  = new Mongo.Collection('lessons');
Scores  = new Mongo.Collection('scores');
Classes = new Mongo.Collection('classes');

Students.allow({
  insert: function(userId, student){
    return student.owner === userId;
  },
  update: function(userId, student, fields, modifier){
    return student.owner === userId;
  },
  remove: function(userId, student){
    return student.owner === userId;
  }
});

Lessons.allow({
  insert: function(userId, lesson){
    return lesson.owner === userId;
  },
  update: function(userId, lesson, fields, modifier){
    return lesson.owner === userId;
  },
  remove: function(userId, lesson){
    return lesson.owner === userId;
  }
});

Classes.allow({
  insert: function(userId, myclass){
    return myclass.owner === userId;
  },
  update: function(userId, myclass, fields, modifier){
    return myclass.owner === userId;
  },
  remove: function(userId, myclass){
    return myclass.owner === userId;
  }
});
