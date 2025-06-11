import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import { useRouter } from 'vue-router'
import api from '../api'

export const useAuthStore = defineStore('auth', () => {
    const router = useRouter()
    const token = ref(localStorage.getItem('token') || null)
    const user = ref(JSON.parse(localStorage.getItem('user')) || null)

    const isAuthenticated = computed(() => !!token.value)
    const userRole = computed(() => user.value?.tipoUsuario || null)
    const userId = computed(() => user.value?.idUsuario || null)

    async function login(credentials) {
        try {
            const { data } = await api.post('/auth/login', credentials)

            token.value = data.token
            user.value = {
                emailOrNick: credentials.emailOrNick,
                tipoUsuario: data.tipoUsuario,
                nombreUsuario: data.nombreUsuario,
                idUsuario: data.idUsuario
            }

            localStorage.setItem('token', data.token)
            localStorage.setItem('user', JSON.stringify(user.value))

            redirectAfterLogin(data.tipoUsuario)
            return { success: true }
        } catch (error) {
            console.error('Login error:', error)
            throw new Error(error.response?.data?.message || 'Credenciales inválidas')
        }
    }

    async function register(userData) {
        try {
            const { data } = await api.post('/auth/register', userData)

            // Solo retornamos éxito sin hacer login automático
            return {
                success: true,
                message: 'Usuario registrado correctamente. Por favor inicia sesión.'
            }
        } catch (error) {
            console.error('Register error:', error)
            const message = error.response?.data?.message || 'Error en el registro'
            return { success: false, message }
        }
    }

    function redirectAfterLogin(role) {
        if (role === 'admin') {
            router.push('/admin')
        } else if (role === 'cliente') {
            router.push('/client')
        }
    }

    function logout() {
        token.value = null
        user.value = null
        localStorage.removeItem('token')
        localStorage.removeItem('user')
        router.push('/home2')
    }

    return { token, user, isAuthenticated, userRole, userId, login, register, logout }
})