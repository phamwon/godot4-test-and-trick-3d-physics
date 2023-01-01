import { defineConfig, loadEnv } from 'vite'
import HttpsCerts from 'vite-plugin-https-certs'

export default defineConfig(({ mode, command }) => {
    // console.log('🤖 ? Vite', { mode, command })
    const env = loadEnv(mode, 'env', '')

    if (command === 'serve') {
        const config = configServe(mode, env)
        // console.log('🤖 ? config', config)
        return config
    }
})

const configDefault = (env) => {
    return {
        appType: 'custom',
        envDir: './env',
        publicDir: false,
        plugins: [            
            HttpsCerts(),
        ]
    }
}

const configServe = (mode, env) => {
    return {
        ...configDefault(env),
        server: {
            hmr: true,
            host: false,
            https: false,
            port: env.PORT || 8060,
            open: '/',
        },
        preview: {
            hmr: false,
            host: true,
            https: false,
            port: env.PORT || 8060,
            open: '/',
        },
        // ? Use for preview
        build: {
            outDir: 'build/html5',
            sourcemap: true,
        },
    }
}