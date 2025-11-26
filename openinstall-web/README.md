# OpenInstall Web 部署指南

这是一个静态网站，可以部署到多个云平台。

## 已更新的配置

- API 地址已更新为：`https://openinstall-backend.zeabur.app/api`

## 部署方式

### 方式 1: Vercel（推荐）

1. **通过 Vercel CLI 部署**：
   ```bash
   # 安装 Vercel CLI
   npm i -g vercel
   
   # 在项目目录下运行
   cd openinstall-web
   vercel
   ```

2. **通过 GitHub 自动部署**：
   - 将代码推送到 GitHub
   - 访问 [vercel.com](https://vercel.com)
   - 导入 GitHub 仓库
   - 选择 `openinstall-web` 目录
   - 点击部署

### 方式 2: Netlify

1. **通过 Netlify CLI 部署**：
   ```bash
   # 安装 Netlify CLI
   npm i -g netlify-cli
   
   # 在项目目录下运行
   cd openinstall-web
   netlify deploy --prod
   ```

2. **通过拖拽部署**：
   - 访问 [netlify.com](https://netlify.com)
   - 直接将 `openinstall-web` 文件夹拖到部署区域

### 方式 3: Cloudflare Pages

1. **通过 Wrangler CLI**：
   ```bash
   # 安装 Wrangler
   npm i -g wrangler
   
   # 登录
   wrangler login
   
   # 部署
   cd openinstall-web
   wrangler pages deploy . --project-name=openinstall-web
   ```

2. **通过 GitHub**：
   - 将代码推送到 GitHub
   - 在 Cloudflare Dashboard 中创建 Pages 项目
   - 连接 GitHub 仓库
   - 构建命令留空，输出目录为 `.`

### 方式 4: GitHub Pages

1. 在 GitHub 仓库中：
   - Settings → Pages
   - Source 选择 `main` 分支
   - 文件夹选择 `/openinstall-web`

2. 访问地址：`https://yourusername.github.io/repo-name/`

### 方式 5: 使用 Docker + Nginx（自托管）

创建 `Dockerfile`：
```dockerfile
FROM nginx:alpine
COPY . /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```

部署：
```bash
docker build -t openinstall-web .
docker run -d -p 80:80 openinstall-web
```

## 自定义配置

部署前，请根据实际情况修改 `index.html` 中的 `CONFIG` 对象：

- `appScheme`: 你的 App URL Scheme（如：`myapp://`）
- `universalLink`: Universal Link 域名
- `iosAppStoreUrl`: iOS App Store 链接
- `androidDownloadUrl`: Android APK 下载链接

## 测试

部署后，访问你的网站，URL 格式示例：
```
https://your-domain.com/?inviteCode=ABC123&channelId=channel1&userId=user123
```

