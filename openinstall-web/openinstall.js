/**
 * OpenInstall Web SDK
 * 设备指纹匹配 + 延迟深度链接
 */

const OpenInstall = (function() {
    'use strict';
    
    /**
     * 从 URL 获取参数
     */
    function getUrlParams() {
        const params = new URLSearchParams(window.location.search);
        return {
            inviteCode: params.get('inviteCode') || '',
            channelId: params.get('channelId') || '',
            userId: params.get('userId') || '',
            custom: params.get('custom') || ''
        };
    }
    
    /**
     * 收集设备指纹
     */
    function collectDeviceFingerprint() {
        const fingerprint = {
            // 基础信息
            userAgent: navigator.userAgent,
            language: navigator.language,
            platform: navigator.platform,
            
            // 屏幕信息
            screenWidth: screen.width,
            screenHeight: screen.height,
            screenColorDepth: screen.colorDepth,
            pixelRatio: window.devicePixelRatio || 1,
            
            // 时区
            timezone: Intl.DateTimeFormat().resolvedOptions().timeZone,
            timezoneOffset: new Date().getTimezoneOffset(),
            
            // Canvas 指纹
            canvasFingerprint: getCanvasFingerprint(),
            
            // WebGL 指纹
            webglFingerprint: getWebGLFingerprint(),
            
            // 字体检测
            fonts: detectFonts(),
            
            // 其他
            cookieEnabled: navigator.cookieEnabled,
            doNotTrack: navigator.doNotTrack || null
        };
        
        return fingerprint;
    }
    
    /**
     * Canvas 指纹
     */
    function getCanvasFingerprint() {
        try {
            const canvas = document.createElement('canvas');
            const ctx = canvas.getContext('2d');
            canvas.width = 200;
            canvas.height = 50;
            
            ctx.textBaseline = 'top';
            ctx.font = '14px Arial';
            ctx.fillStyle = '#f60';
            ctx.fillRect(125, 1, 62, 20);
            ctx.fillStyle = '#069';
            ctx.fillText('Device Fingerprint', 2, 15);
            
            return canvas.toDataURL();
        } catch (e) {
            return 'unsupported';
        }
    }
    
    /**
     * WebGL 指纹
     */
    function getWebGLFingerprint() {
        try {
            const canvas = document.createElement('canvas');
            const gl = canvas.getContext('webgl') || canvas.getContext('experimental-webgl');
            
            if (!gl) return null;
            
            const debugInfo = gl.getExtension('WEBGL_debug_renderer_info');
            if (!debugInfo) return null;
            
            return {
                vendor: gl.getParameter(debugInfo.UNMASKED_VENDOR_WEBGL),
                renderer: gl.getParameter(debugInfo.UNMASKED_RENDERER_WEBGL)
            };
        } catch (e) {
            return null;
        }
    }
    
    /**
     * 字体检测
     */
    function detectFonts() {
        const testFonts = [
            'Arial', 'Verdana', 'Times New Roman', 'Courier New',
            'Georgia', 'Palatino', 'Garamond', 'Bookman',
            'Comic Sans MS', 'Trebuchet MS', 'Impact'
        ];
        
        const detectedFonts = [];
        
        testFonts.forEach(font => {
            if (isFontAvailable(font)) {
                detectedFonts.push(font);
            }
        });
        
        return detectedFonts;
    }
    
    /**
     * 检测字体是否可用
     */
    function isFontAvailable(fontName) {
        const canvas = document.createElement('canvas');
        const context = canvas.getContext('2d');
        const text = 'mmmmmmmmmmlli';
        
        context.font = '72px monospace';
        const baselineWidth = context.measureText(text).width;
        
        context.font = `72px '${fontName}', monospace`;
        const testWidth = context.measureText(text).width;
        
        return baselineWidth !== testWidth;
    }
    
    /**
     * 生成设备指纹ID
     */
    function generateFingerprintId(fingerprint) {
        const str = JSON.stringify(fingerprint);
        let hash = 0;
        for (let i = 0; i < str.length; i++) {
            const char = str.charCodeAt(i);
            hash = ((hash << 5) - hash) + char;
            hash = hash & hash; // Convert to 32bit integer
        }
        return Math.abs(hash).toString(36);
    }
    
    /**
     * 上传数据到服务器
     */
    async function uploadToServer(apiBaseUrl) {
        const params = getUrlParams();
        const fingerprint = collectDeviceFingerprint();
        const fingerprintId = generateFingerprintId(fingerprint);
        
        const data = {
            fingerprintId: fingerprintId,
            fingerprint: fingerprint,
            params: params,
            timestamp: Date.now(),
            referrer: document.referrer,
            url: window.location.href
        };
        
        try {
            const response = await fetch(`${apiBaseUrl}/tracking/save`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify(data)
            });
            
            if (!response.ok) {
                throw new Error(`HTTP error! status: ${response.status}`);
            }
            
            const result = await response.json();
            
            if (!result.success) {
                throw new Error(result.message || '上传失败');
            }
            
            console.log('数据上传成功:', result);
            return result;
        } catch (error) {
            console.error('数据上传失败:', error);
            throw error;
        }
    }
    
    /**
     * 尝试拉起 App
     */
    function tryWakeupApp(config) {
        const params = getUrlParams();
        const query = new URLSearchParams(params).toString();
        
        // 尝试使用 URL Scheme
        if (config.appScheme) {
            const schemeUrl = `${config.appScheme}open?${query}`;
            window.location.href = schemeUrl;
        }
        
        // 尝试使用 Universal Link
        if (config.universalLink) {
            setTimeout(() => {
                const universalUrl = `${config.universalLink}/open?${query}`;
                window.location.href = universalUrl;
            }, 500);
        }
    }
    
    // 公开 API
    return {
        getUrlParams: getUrlParams,
        collectDeviceFingerprint: collectDeviceFingerprint,
        generateFingerprintId: generateFingerprintId,
        uploadToServer: uploadToServer,
        tryWakeupApp: tryWakeupApp
    };
})();

// 如果在浏览器环境中，将 OpenInstall 挂载到 window
if (typeof window !== 'undefined') {
    window.OpenInstall = OpenInstall;
}

// 如果在 Node.js 环境中，导出模块
if (typeof module !== 'undefined' && module.exports) {
    module.exports = OpenInstall;
}

