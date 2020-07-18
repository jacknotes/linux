create user ${user} identified by "${passwd}";
grant all on ApolloConfigDB.* to "${user}"@'%' identified by "${passwd}";
grant all on ApolloPortalDB.* to "${user}"@'%' identified by "${passwd}";
flush privileges;

