<template>
  <main class="tickets-container">
    <header class="page-header">
      <h2 class="main-title">
        <Ticket class="title-icon" :size="28" />
        我的票夹
      </h2>
      <p class="subtitle">管理您的所有购票订单</p>
    </header>

    <div class="tabs-wrapper">
      <div class="tabs-container">
        <button 
          v-for="tab in tabs" 
          :key="tab.value"
          class="tab-btn" 
          :class="{ active: activeTab === tab.value }"
          @click="activeTab = tab.value"
        >
          {{ tab.label }}
        </button>
      </div>
    </div>

    <div class="ticket-list">
      <div v-if="filteredTickets.length === 0" class="empty-state">
        <Inbox class="empty-icon" :size="48" :stroke-width="1.5" />
        <p>这里空空如也，快去大厅逛逛吧~</p>
      </div>

      <div 
        v-for="ticket in filteredTickets" 
        :key="ticket.ticketId" 
        class="ticket-card"
      >
        <div class="ticket-top">
          <h3 class="event-title">{{ ticket.eventTitle }}</h3>
          <span class="status-tag" :class="ticket.status">
            {{ getStatusText(ticket.status) }}
          </span>
        </div>

        <div class="ticket-info">
          <div class="info-row">
            <div class="info-item">
              <Clock class="info-icon" :size="16" />
              <span>{{ formatTime(ticket.startTime) }}</span>
            </div>
            <div class="info-item">
              <MapPin class="info-icon" :size="16" />
              <span>{{ ticket.venueName }}</span>
            </div>
          </div>
          </div>

        <div class="ticket-actions">
          
          <div class="ticket-id pill-capsule">订单编号: #{{ ticket.ticketId }}</div>
          
          <div class="action-btn-group">
            <button 
              v-if="ticket.status === 'Unpaid'" 
              class="action-btn cancel-btn"
              @click="handleFakeCancel"
            >
              <XCircle :size="16" />
              取消订单
            </button>

            <button 
              v-if="ticket.status === 'Paid'" 
              class="action-btn delete-btn"
              @click="handleRealCancel(ticket.ticketId, ticket.eventId)"
            >
              <Undo2 :size="16" />
              退票 / 删除
            </button>

            <button 
              v-if="ticket.status === 'Completed'" 
              class="action-btn review-btn"
              @click="handleFakeReview"
            >
              <MessageSquare :size="16" />
              待评价
            </button>
          </div>
        </div>
      </div>
    </div>
  </main>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import axios from 'axios'
// 引入专业线性图标
import { Ticket, Inbox, Clock, MapPin, XCircle, Undo2, MessageSquare } from 'lucide-vue-next'

// 所有的票据数据
const tickets = ref<any[]>([])

// 状态栏数据
const tabs = [
  { label: '未支付', value: 'Unpaid' },
  { label: '已支付', value: 'Paid' },
  { label: '已结束', value: 'Completed' }
]
const activeTab = ref('Paid') // 默认选中已支付

// 核心过滤逻辑
const filteredTickets = computed(() => {
  return tickets.value.filter(t => t.status === activeTab.value)
})

// 从后端获取所有票
const fetchMyTickets = async () => {
  try {
    const userId = localStorage.getItem('userId')
    const res = await axios.get(`http://localhost:8080/ticket/my?userId=${userId}`)
    if (res.data.code === 200) {
      tickets.value = res.data.data
    }
  } catch (error) {
    console.error('获取票夹失败', error)
  }
}

// 1. 真退票逻辑 (Paid)
const handleRealCancel = async (ticketId: number, eventId: number) => {
  if (!confirm('退票后不可恢复，确定要退票吗？')) return

  try {
    const res = await axios.post(`http://localhost:8080/ticket/refund?orderId=${ticketId}`)
    if (res.data.code === 200) {
      alert('✅ 退票成功，库存已恢复！')
      fetchMyTickets() 
    } else {
      alert('❌ 退票失败: ' + res.data.msg)
    }
  } catch (error) {
    console.error('退票出错', error)
  }
}

// 2. 假取消逻辑 (Unpaid)
const handleFakeCancel = () => {
  alert('您的未支付订单已取消 (演示功能)')
}

// 3. 假评价逻辑 (Completed)
const handleFakeReview = () => {
  alert('感谢您的参与，评价系统即将上线！(演示功能)')
}

const formatTime = (timeStr: string) => {
  if (!timeStr) return ''
  return timeStr.replace('T', ' ').substring(0, 16)
}

const getStatusText = (status: string) => {
  const map: Record<string, string> = { 'Unpaid': '待支付', 'Paid': '已购票', 'Completed': '已结束' }
  return map[status] || status
}

onMounted(() => {
  fetchMyTickets()
})
</script>

<style scoped>
/* ================= 全局颜色变量 (大麦官方规范) ================= */
.tickets-container {
  --primary-red: #FF1268;
  --primary-orange: #FF5400;
  --bg-light: #F5F6F8;
  --text-primary: #1D2129;
  --text-secondary: #666666;
  --text-white: #FFFFFF;
  --border-light: #E5E6EB;

  max-width: 800px;
  margin: 0 auto;
  padding: 30px 20px;
}

/* ================= 头部 ================= */
.page-header {
  margin-bottom: 24px;
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

/* ================= 横向滚动状态栏 ================= */
.tabs-wrapper {
  margin-bottom: 24px;
  position: relative;
}

.tabs-container {
  display: flex;
  overflow-x: auto;
  white-space: nowrap;
  gap: 12px;
  padding-bottom: 4px;
  scrollbar-width: none; 
}
.tabs-container::-webkit-scrollbar {
  display: none; 
}

.tab-btn {
  background: var(--text-white);
  border: 1px solid var(--border-light);
  padding: 8px 24px;
  border-radius: 999px; /* 胶囊型 */
  font-size: 0.95rem;
  font-weight: 500;
  color: var(--text-secondary);
  cursor: pointer;
  transition: all 0.2s ease;
}

.tab-btn:hover {
  color: var(--primary-red);
  border-color: #ffd0de;
}

.tab-btn.active {
  background: var(--primary-red);
  color: var(--text-white);
  border-color: var(--primary-red);
  box-shadow: 0 4px 12px rgba(255, 18, 104, 0.25);
  font-weight: bold;
}

/* ================= 卡片列表 ================= */
.ticket-list {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.empty-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 60px 0;
  color: var(--text-secondary);
}

.empty-icon {
  color: #ccc;
  margin-bottom: 16px;
}

.ticket-card {
  position: relative; /* 核心：为右上角渐变光效做定位 */
  overflow: hidden;   /* 核心：保证光效不溢出卡片圆角 */
  background: var(--text-white);
  border: 1px solid var(--border-light);
  border-radius: 16px;
  padding: 24px;
  box-shadow: 0 2px 10px rgba(0, 0, 0, 0.02);
  transition: all 0.2s ease;
}

/* 右上角圆形渐变色光效 (默认隐藏) */
.ticket-card::before {
  content: "";
  position: absolute;
  top: -50px;
  right: -50px;
  width: 140px;
  height: 140px;
  background: radial-gradient(circle, rgba(255, 18, 104, 0.12) 0%, transparent 70%);
  border-radius: 50%;
  opacity: 0;
  transition: opacity 0.3s ease;
  pointer-events: none;
}

/* 悬停状态：卡片上浮、边框变红、光效浮现 */
.ticket-card:hover {
  transform: translateY(-3px);
  box-shadow: 0 8px 24px rgba(0, 0, 0, 0.06);
  border-color: var(--primary-red);
}
.ticket-card:hover::before {
  opacity: 1; 
}

/* 点击状态：微微下陷缩小的点击反馈 */
.ticket-card:active {
  transform: translateY(-1px) scale(0.98);
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.04);
}

/* 保证内部文字不被渐变光效遮挡 */
.ticket-top, .ticket-info, .ticket-actions {
  position: relative;
  z-index: 1;
}

.ticket-top {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 16px;
}

.event-title {
  margin: 0;
  font-size: 1.25rem;
  color: var(--text-primary);
  font-weight: bold;
  line-height: 1.4;
  padding-right: 16px;
}

/* 状态标签 */
.status-tag {
  font-size: 0.85rem;
  padding: 4px 12px;
  border-radius: 999px;
  font-weight: bold;
  white-space: nowrap;
}
.Unpaid { background: #FFF1E6; color: var(--primary-orange); }
.Paid { background: #FFF0F4; color: var(--primary-red); }
.Completed { background: var(--bg-light); color: var(--text-secondary); }

/* ================= 信息区排版 ================= */
.ticket-info {
  display: flex;
  flex-direction: column;
  gap: 10px;
}

.info-row {
  display: flex;
  flex-direction: row;
  flex-wrap: wrap;
  gap: 16px; 
}

.info-item {
  display: flex;
  align-items: center;
  gap: 6px;
  color: var(--text-secondary);
  font-size: 1.05rem; 
  font-weight: 500;
}

.info-icon {
  color: #999;
}

/* ================= 底部操作区 (分割线以下) ================= */
.ticket-actions {
  margin-top: 20px;
  padding-top: 16px;
  border-top: 1px dashed var(--border-light); /* 这是那条虚线分割线 */
  display: flex;
  justify-content: space-between; /* 核心：左边放编号胶囊，右边放按钮 */
  align-items: center; /* 垂直居中对齐 */
}

/* 新增：和大厅首页一致的胶囊样式 */
.pill-capsule {
  background-color: #FFF0F4; /* 极浅的大麦红背景 */
  color: var(--primary-red); /* 大麦红字体 */
  padding: 4px 12px;
  border-radius: 999px; /* 极限圆角实现胶囊态 */
  font-size: 0.85rem;
  font-weight: bold;
  font-family: monospace; /* 保留一点数字代码的感觉 */
}

/* 按钮组 */
.action-btn-group {
  display: flex;
  gap: 12px;
}

.action-btn {
  display: flex;
  align-items: center;
  gap: 6px;
  padding: 8px 20px;
  border-radius: 999px;
  font-size: 0.95rem;
  font-weight: 500;
  cursor: pointer;
  background: transparent;
  transition: all 0.2s ease;
}

/* 按钮线框风格 */
.cancel-btn { 
  border: 1px solid var(--border-light); 
  color: var(--text-secondary); 
}
.cancel-btn:hover {
  background: var(--bg-light);
  color: var(--text-primary);
  border-color: var(--text-secondary);
}

.delete-btn { 
  border: 1px solid #ffa39e; 
  color: var(--primary-red); 
}
.delete-btn:hover { 
  background: #FFF0F4; 
  border-color: var(--primary-red);
}

.review-btn { 
  border: 1px solid var(--primary-orange); 
  color: var(--primary-orange); 
}
.review-btn:hover { 
  background: #FFF1E6; 
}
</style>