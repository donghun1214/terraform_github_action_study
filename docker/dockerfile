#node 버전 베이스 이미지 생성
FROM node:20.11.1  

# working directory 생성. 워킹 디렉토리를 생성함으로써 copy, and, run 
# 등의 명령어를 상대경로에서 작동할 수 있게 함. 디렉토리 구조 명확하게 하여 사용하기 편하게 함.
WORKDIR /usr/src/app  

# nodeJS 의 의존성 파일들을 COPY 한다.
COPY package*.json .  
 # 기입된 의존성 파일들이 적힌 내용대로 설치한다. 
RUN npm install       

# 현재 위치한 모든 파일들을 도커 컨테이너에 복사한다.
COPY . .               
# 도커 컨테이너의 포트번호를 명시한다.
EXPOSE 3000
## 해당 명령문을 실행한다.
CMD ["node","index.js"]