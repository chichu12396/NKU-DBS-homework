<template>
  <main class="admin-container">
    <header class="admin-header">
      <div class="header-titles">
        <h2 class="main-title">
          <Settings class="title-icon" :size="28" />
          活动管理后台
        </h2>
        <p class="subtitle">管理所有活动的上架、下架与状态结算</p>
      </div>
      <button class="primary-btn add-btn" @click="showAddModal = true">
        <Plus :size="18" />
        发布新活动
      </button>
    </header>

    <div class="columns-wrapper">
      <section class="event-column">
        <h2 class="column-title">
          <BookOpen class="section-icon" :size="20" />
          学术讲座管理
        </h2>
        <div class="event-list">
          <div v-for="item in lectureList" :key="item.eventId" class="event-card">
            <h3 class="event-title">{{ item.eventTitle }}</h3>
            
            <div class="event-info">
              <div class="info-item">
                <Clock class="lucide-icon" :size="16" />
                <span>{{ formatTime(item.startTime) }}</span>
              </div>
              <div class="info-item">
                <MapPin class="lucide-icon" :size="16" />
                <span>{{ item.venueName }}</span>
              </div>
              <div class="info-item stock-item">
                <Ticket class="lucide-icon" :size="16" />
                <span>余票: <strong :class="{'low-stock': item.availTix < 10}">{{ item.availTix }}</strong></span>
              </div>
            </div>

            <div class="admin-actions">
              <button class="action-btn complete-btn" @click="handleComplete(item.eventId)">
                <CheckCircle :size="14" /> 结算结束
              </button>
              <button class="action-btn delete-btn" @click="handleDelete(item.eventId)">
                <Trash2 :size="14" /> 删除活动
              </button>
            </div>
          </div>
          <div v-if="lectureList.length === 0" class="empty-state">暂无讲座</div>
        </div>
      </section>

      <section class="event-column">
        <h2 class="column-title">
          <Drama class="section-icon" :size="20" />
          文艺演出管理
        </h2>
        <div class="event-list">
          <div v-for="item in performanceList" :key="item.eventId" class="event-card">
            <h3 class="event-title">{{ item.eventTitle }}</h3>
            
            <div class="event-info">
              <div class="info-item">
                <Clock class="lucide-icon" :size="16" />
                <span>{{ formatTime(item.startTime) }}</span>
              </div>
              <div class="info-item">
                <MapPin class="lucide-icon" :size="16" />
                <span>{{ item.venueName }}</span>
              </div>
              <div class="info-item stock-item">
                <Ticket class="lucide-icon" :size="16" />
                <span>余票: <strong :class="{'low-stock': item.availTix < 10}">{{ item.availTix }}</strong></span>
              </div>
            </div>

            <div class="admin-actions">
              <button class="action-btn complete-btn" @click="handleComplete(item.eventId)">
                <CheckCircle :size="14" /> 结算结束
              </button>
              <button class="action-btn delete-btn" @click="handleDelete(item.eventId)">
                <Trash2 :size="14" /> 删除活动
              </button>
            </div>
          </div>
          <div v-if="performanceList.length === 0" class="empty-state">暂无演出</div>
        </div>
      </section>
    </div>

    <div v-if="showAddModal" class="modal-overlay">
      <div class="modal-card">
        <h3 class="modal-title">
          <PlusCircle :size="24" class="modal-title-icon" />
          发布新活动
        </h3>
        <form @submit.prevent="handleAddEvent" class="add-form">
          <div class="form-group">
            <label>活动标题</label>
            <input v-model="newEvent.title" type="text" required placeholder="请输入活动名称" />
          </div>
          
          <div class="form-group-row">
            <div class="form-group">
              <label>活动类型</label>
              <select v-model="newEvent.eventType" required>
                <option value="Lecture">学术讲座 (Lecture)</option>
                <option value="Performance">文艺演出 (Performance)</option>
              </select>
            </div>
            <div class="form-group">
              <label>发行票数</label>
              <input v-model="newEvent.availTix" type="number" required min="1" />
            </div>
          </div>

          <div class="form-group-row">
            <div class="form-group">
              <label>开始时间</label>
              <input v-model="newEvent.startTime" type="datetime-local" required />
            </div>
            <div class="form-group">
              <label>结束时间</label>
              <input v-model="newEvent.endTime" type="datetime-local" required />
            </div>
          </div>

          <div class="form-group-row">
            <div class="form-group">
              <label>主办方 ID</label>
              <input v-model="newEvent.organizerId" type="number" required placeholder="例如: 1" />
            </div>
            <div class="form-group">
              <label>场馆 ID</label>
              <input v-model="newEvent.venueId" type="number" required placeholder="例如: 1" />
            </div>
          </div>

          <div class="modal-actions">
            <button type="button" class="action-btn cancel-btn" @click="showAddModal = false">取消</button>
            <button type="submit" class="primary-btn">
              <Send :size="16" />
              立即发布
            </button>
          </div>
        </form>
      </div>
    </div>
  </main>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import axios from 'axios'
// 引入 Lucide 线性图标
import { Settings, Plus, BookOpen, Drama, Clock, MapPin, Ticket, CheckCircle, Trash2, PlusCircle, Send } from 'lucide-vue-next'

// 接口定义
interface EventDetail {
  eventId: number
  eventTitle: string
  startTime: string
  availTix: number
  eventType: string
  venueName: string
}

// 数据状态
const lectureList = ref<EventDetail[]>([])
const performanceList = ref<EventDetail[]>([])
const showAddModal = ref(false)

// 新建活动的表单数据
const newEvent = reactive({
  title: '',
  eventType: 'Lecture',
  availTix: 100,
  startTime: '',
  endTime: '',
  organizerId: '',
  venueId: ''
})

// 1. 获取并分类活动列表
const fetchEvents = async () => {
  try {
    const response = await axios.get('http://localhost:8080/event/list')
    if (response.data.code === 200) {
      const allEvents = response.data.data
      lectureList.value = allEvents.filter((e: EventDetail) => e.eventType === 'Lecture')
      performanceList.value = allEvents.filter((e: EventDetail) => e.eventType === 'Performance' || e.eventType === 'Performances')
    }
  } catch (error) {
    console.error('获取列表失败:', error)
  }
}

// 2. 结算活动
const handleComplete = async (eventId: number) => {
  if (!confirm('确定要手动触发该活动的结算吗？(会校验时间是否结束)')) return
  try {
    const res = await axios.post(`http://localhost:8080/event/complete?eventId=${eventId}`)
    if (res.data.code === 200) {
      alert('✅ ' + res.data.data)
    } else {
      alert('❌ 结束失败，活动尚未结束')
    }
  } catch (error) {
    console.error('结算请求失败', error)
  }
}

// 3. 删除活动
const handleDelete = async (eventId: number) => {
  if (!confirm('🚨 危险操作：确定要下架并删除该活动吗？')) return
  try {
    const res = await axios.post(`http://localhost:8080/event/delete?eventId=${eventId}`)
    if (res.data.code === 200) {
      alert('✅ 删除成功！')
      fetchEvents() 
    } else {
      alert('❌ ' + res.data.msg)
    }
  } catch (error) {
    console.error('删除请求失败', error)
  }
}

// 4. 发布新活动
const handleAddEvent = async () => {
  try {
    const payload = {
      ...newEvent,
      startTime: newEvent.startTime + ':00',
      endTime: newEvent.endTime + ':00'
    }

    const res = await axios.post('http://localhost:8080/event/add', payload)
    
    if (res.data.code === 200) {
      alert('🎉 ' + res.data.data)
      showAddModal.value = false 
      fetchEvents() 
      
      newEvent.title = ''
      newEvent.startTime = ''
      newEvent.endTime = ''
    } else {
      alert('❌ 发布失败：' + res.data.msg)
    }
  } catch (error) {
    console.error('添加失败', error)
    alert('请求失败，请检查填写的数据格式')
  }
}

// 格式化时间显示
const formatTime = (timeStr: string) => {
  if (!timeStr) return ''
  return timeStr.replace('T', ' ').substring(0, 16)
}

onMounted(() => {
  fetchEvents()
})
</script>

<style scoped>
/* ================= 全局颜色变量 (大麦官方规范) ================= */
.admin-container {
  --primary-red: #FF1268;
  --primary-orange: #FF5400;
  --bg-light: #F5F6F8;
  --text-primary: #1D2129;
  --text-secondary: #666666;
  --text-white: #FFFFFF;
  --border-light: #E5E6EB;

  max-width: 1200px;
  margin: 0 auto;
  padding: 30px 20px;
}

/* ================= 头部区域 ================= */
.admin-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 40px;
  border-bottom: 1px solid var(--border-light);
  padding-bottom: 24px;
}

.main-title {
  display: flex;
  align-items: center;
  gap: 10px;
  font-size: 1.8rem;
  color: var(--text-primary);
  margin: 0 0 8px 0;
}

.title-icon {
  color: var(--primary-red);
}

.subtitle { 
  color: var(--text-secondary); 
  font-size: 1rem; 
  margin: 0; 
}

/* 核心发布按钮 */
.primary-btn {
  display: flex;
  align-items: center;
  gap: 6px;
  background: var(--primary-red);
  color: var(--text-white);
  border: none;
  padding: 12px 24px;
  font-size: 1.05rem;
  font-weight: bold;
  border-radius: 999px;
  cursor: pointer;
  box-shadow: 0 4px 15px rgba(255, 18, 104, 0.25);
  transition: all 0.2s ease;
}
.primary-btn:hover {
  background: #e00d5a;
  transform: translateY(-2px);
  box-shadow: 0 6px 20px rgba(255, 18, 104, 0.35);
}

/* ================= 列表布局 ================= */
.columns-wrapper {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 30px;
}

.column-title { 
  display: flex;
  align-items: center;
  gap: 8px;
  color: var(--text-primary); 
  margin-bottom: 20px; 
  font-size: 1.25rem;
}

.section-icon {
  color: var(--primary-orange);
}

.event-list {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

/* ================= 纯白管理卡片 ================= */
.event-card {
  position: relative; /* 为右上角渐变做定位 */
  overflow: hidden; /* 保证渐变不溢出圆角 */
  background-color: var(--text-white);
  border: 1px solid var(--border-light);
  border-radius: 12px;
  padding: 20px;
  cursor: pointer;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.04);
  transition: all 0.2s ease;
  display: flex;
  flex-direction: column;
  justify-content: space-between;
}

/* 右上角圆形渐变色预设 (默认隐藏) */
.event-card::before {
  content: "";
  position: absolute;
  top: -50px;
  right: -50px;
  width: 140px;
  height: 140px;
  /* 使用大麦红的半透明径向渐变 */
  background: radial-gradient(circle, rgba(255, 18, 104, 0.12) 0%, transparent 70%);
  border-radius: 50%;
  opacity: 0;
  transition: opacity 0.3s ease;
  pointer-events: none; /* 防止遮挡点击事件 */
}

/* 悬停状态：保留上升并显示右上角渐变 */
.event-card:hover {
  transform: translateY(-3px);
  box-shadow: 0 8px 20px rgba(0, 0, 0, 0.08);
  border-color: var(--primary-red); 
}
.event-card:hover::before {
  opacity: 1; /* 悬停时渐变浮现 */
}
.card-content {
  margin-bottom: 20px;
  position: relative;
  z-index: 1; /* 保证文字在渐变色上方 */
}
.event-title {
  margin: 0 0 12px 0;
  font-size: 1.2rem;
  font-weight: 600;
  color: var(--text-primary);
  line-height: 1.4;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}

.event-info {
  display: flex;
  flex-direction: row; 
  flex-wrap: wrap; 
  gap: 32px; 
}

/* 修改点：增大字体 */
.info-item {
  display: flex;
  align-items: center;
  gap: 6px;
  color: var(--text-secondary);
  font-size: 1.05rem; /* 从 0.9rem 增大到 1.05rem */
  font-weight: 500;
}

.lucide-icon {
  color: #999;
}

.stock-item strong {
  color: var(--text-primary);
}

.stock-item .low-stock {
  color: var(--primary-orange);
}

/* ================= 后台操作区 ================= */
.admin-actions {
  display: flex;
  gap: 12px;
  justify-content: flex-end;
  border-top: 1px dashed var(--border-light);
  padding-top: 16px;
}

.action-btn {
  display: flex;
  align-items: center;
  gap: 4px;
  padding: 6px 16px;
  border-radius: 999px;
  font-size: 0.9rem;
  font-weight: 500;
  cursor: pointer;
  background: transparent;
  transition: all 0.2s;
}

/* 结算按钮 - 黑色线框风格 */
.complete-btn { 
  border: 1px solid var(--border-light); 
  color: var(--text-primary); 
}
.complete-btn:hover { 
  border-color: var(--text-primary);
  background: var(--bg-light); 
}

/* 删除按钮 - 红色线框风格 */
.delete-btn { 
  border: 1px solid #ffa39e; 
  color: var(--primary-red); 
}
.delete-btn:hover { 
  background: #FFF0F4; 
  border-color: var(--primary-red);
}

.empty-state { text-align: center; color: var(--text-secondary); padding: 40px 0; }

/* ================= 弹窗专属样式 ================= */
.modal-overlay {
  position: fixed;
  top: 0; left: 0; right: 0; bottom: 0;
  background: rgba(0, 0, 0, 0.45);
  backdrop-filter: blur(4px);
  display: flex;
  justify-content: center;
  align-items: center;
  z-index: 1000;
}

.modal-card {
  width: 100%;
  max-width: 520px;
  background: var(--text-white);
  border-radius: 16px;
  padding: 32px;
  box-shadow: 0 20px 40px rgba(0, 0, 0, 0.15);
  animation: slideUp 0.3s ease-out;
}

@keyframes slideUp {
  from { opacity: 0; transform: translateY(20px); }
  to { opacity: 1; transform: translateY(0); }
}

.modal-title { 
  display: flex;
  align-items: center;
  gap: 8px;
  margin-top: 0; 
  color: var(--text-primary); 
  margin-bottom: 24px;
  font-size: 1.4rem;
}

.modal-title-icon {
  color: var(--primary-red);
}

.form-group {
  display: flex;
  flex-direction: column;
  margin-bottom: 16px;
  flex: 1;
}

.form-group-row {
  display: flex;
  gap: 16px;
}

.form-group label { 
  margin-bottom: 6px; 
  font-size: 0.9rem; 
  color: var(--text-secondary); 
  font-weight: 500;
}

.form-group input, .form-group select {
  padding: 10px 14px;
  border: 1px solid var(--border-light);
  border-radius: 8px;
  font-size: 1rem;
  background: var(--bg-light);
  color: var(--text-primary);
  outline: none;
  transition: all 0.2s;
}

.form-group input:focus, .form-group select:focus {
  background: var(--text-white);
  border-color: var(--primary-red);
  box-shadow: 0 0 0 3px rgba(255, 18, 104, 0.1);
}

.modal-actions {
  display: flex;
  justify-content: flex-end;
  gap: 12px;
  margin-top: 32px;
}

.cancel-btn { 
  background: transparent; 
  color: var(--text-secondary); 
  border: 1px solid var(--border-light);
  padding: 10px 24px;
}
.cancel-btn:hover { 
  background: var(--bg-light); 
  color: var(--text-primary);
}
</style>