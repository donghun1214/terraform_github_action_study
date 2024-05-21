
import express from 'express';
import { fileURLToPath } from 'url';
import path from 'path';
import { promises as fs } from 'fs';

const app = express();
const port = 3000;
const USERS_JSON_FILENAME = 'users.json';

//users.json 의 내용 다 들고오기
async function fetchAllUsers() {
    const data = await fs.readFile(USERS_JSON_FILENAME);
    const users = JSON.parse(data.toString());
    return users;
}

//해당 user 있는 지 확인
async function fetchUser(username) {
    const users = await fetchAllUsers();
    const user = users.find((user) => user.username === username);
    return user;
}

async function createUser(newUser) {
    const users = await fetchAllUsers();
    users.push(newUser);
    await fs.writeFile(USERS_JSON_FILENAME, JSON.stringify(users));
}

// 현재 실행 중인 스크립트가 위치한 경로를 나타내는 변수 '__dirname'
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

//json 파싱
app.use(express.json());

/**
app.get("/", (req, res) => {
    res.sendFile(__dirname + "/week2.html");
});
 */

app.post("/api/signup", async (req, res) => {
  const {username, password, email} = req.body;
  const user = await fetchUser(username);
  if(user){
    res.status(400).send(`duplicate name : ${username}`);
    return;
  }

  const newUser = {
    username,
    password,
    email
    };
  await createUser(newUser);
  res.status(201).send(`User created: ${username}`); // 사용자 생성에 대한 응답 추가
}); 

app.post('/api/login', async (req, res) => {
    const { username, password } = req.body;
    const user = await fetchUser(username);

    // 가입 안 된 username인 경우
    if (!user) {
        res.status(401).send(`not registered username: ${username}`);
        return;
    }

    // 비밀번호가 틀렸을 경우
    if (password !== user.password) {
        res.status(401).send('incorrect password');
        return;
    }

    res.status(200).send(`login OK`);
});


app.get('/api/users', async(req, res) => {
    const users = await fetchAllUsers(); 
    //구조 분해 할당. password 이외의 부분을 따로 변수에 담는다.
    const usersWithoutPasswords = users.map(({ password, ...rest }) => rest);
    res.send(usersWithoutPasswords);
});


app.listen(port, () => {
    console.log(`Server running at http://localhost:${port}`);
});
