# OpenInstall Backend

Spring Boot 后端服务 - 设备指纹匹配 + 延迟深度链接

## 技术栈

- Spring Boot 3.2.0
- Spring Data Redis
- Java 17
- Maven

## 快速开始

### 1. 环境要求

- JDK 17+
- Maven 3.6+
- Redis 6.0+

### 2. 安装依赖

```bash
mvn clean install
```

### 3. 配置 Redis

编辑 `src/main/resources/application.yml`:

```yaml
spring:
  data:
    redis:
      host: localhost
      port: 6379
      password:  # 如有密码，填写此处
```

### 4. 启动服务

```bash
mvn spring-boot:run
```

服务将在 `http://localhost:8080` 启动

## API 文档

### 保存追踪数据

**POST** `/api/tracking/save`

保存 Web 端上传的设备指纹和参数

### 获取追踪数据

**POST** `/api/tracking/get`

App 端通过设备指纹匹配获取参数

### 健康检查

**GET** `/api/tracking/health`

检查服务状态

## 配置说明

详见 `src/main/resources/application.yml`

## 开发

### 运行测试

```bash
mvn test
```

### 打包

```bash
mvn clean package
```

生成的 JAR 文件在 `target/` 目录

### 运行 JAR

```bash
java -jar target/openinstall-backend-1.0.0.jar
```

## 生产环境部署

1. 配置 Redis 集群
2. 设置环境变量或修改 `application-prod.yml`
3. 使用 Docker 或直接运行 JAR


