const http = require("http").createServer();
const io = require("socket.io")(http);

http.listen(3031);

const rooms = [];
const users = [];

io.on("connection", (socket) => {
  // 部屋を新しく建てる
  socket.on("create", (userName) => {
    // ランダムな部屋IDを生成する(メソッドの中身は以下参照)
    // https://github.com/mega-yadoran/web-socket-online-battle/blob/master/server/index.js#L123-L131
    const roomId = generateRoomId(); 

    // ユーザー・部屋の情報をそれぞれデータとして格納する
    const user = { id: socket.id, name: userName, roomId };
    const room = {
      id: roomId,
      users: [user],
      turnUserIndex: 0,
      posts: [],
    };
    rooms.push(room);
    users.push(user);

    // 部屋に入る
    socket.join(roomId);

    // 部屋情報をクライアントに送る
    io.to(socket.id).emit("updateRoom", room);
  });
});