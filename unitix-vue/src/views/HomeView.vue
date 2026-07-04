<template>
  <main class="home-container">
    <div class="header-section">
      <h1 class="main-title">
        <Ticket class="title-icon" :size="32" />
        校园大麦 - 购票大厅
      </h1>
      <p class="subtitle">探索近期校园精彩活动</p>
    </div>

    <div class="columns-wrapper">
      
      <section class="event-column">
        <h2 class="column-title">
          <BookOpen class="section-icon" :size="20" />
          学术讲座
        </h2>
        <div class="event-list">
          <div 
            v-for="item in lectureList" 
            :key="item.eventId" 
            class="event-card"
            @click="goToDetail(item.eventId)"
          >
            <div class="card-content">
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
              </div>
            </div>
            <div class="card-footer">
              <span class="organizer pill-capsule">{{ item.organizerName }}</span>
              <div class="stock-container">
                <span class="stock-label">余票</span>
                <span class="stock-number" :class="{ 'low-stock': item.availTix < 10 }">
                  {{ item.availTix }}
                </span>
              </div>
            </div>
          </div>
          <div v-if="lectureList.length === 0" class="empty-state">暂无讲座活动</div>
        </div>
      </section>

      <section class="event-column">
        <h2 class="column-title">
          <Drama class="section-icon" :size="20" />
          文艺演出
        </h2>
        <div class="event-list">
          <div 
            v-for="item in performanceList" 
            :key="item.eventId" 
            class="event-card"
            @click="goToDetail(item.eventId)"
          >
            <div class="card-content">
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
              </div>
            </div>
            <div class="card-footer">
              <span class="organizer pill-capsule">{{ item.organizerName }}</span>
              <div class="stock-container">
                <span class="stock-label">余票</span>
                <span class="stock-number" :class="{ 'low-stock': item.availTix < 10 }">
                  {{ item.availTix }}
                </span>
              </div>
            </div>
          </div>
          <div v-if="performanceList.length === 0" class="empty-state">暂无演出活动</div>
        </div>
      </section>

    </div>
  </main>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import axios from 'axios'
// 引入 Lucide 线性图标
import { Ticket, BookOpen, Drama, Clock, MapPin } from 'lucide-vue-next'

const router = useRouter()

// 定义数据的类型
interface EventDetail {
  eventId: number
  eventTitle: string
  startTime: string
  availTix: number
  eventType: string
  organizerName: string
  venueName: string
  venueLocation: string
}

// 响应式数据
const lectureList = ref<EventDetail[]>([])
const performanceList = ref<EventDetail[]>([])

// 获取活动列表并分类
const fetchEvents = async () => {
  try {
    const response = await axios.get('http://localhost:8080/event/list')
    const allEvents = response.data.data 
    lectureList.value = allEvents.filter((e: EventDetail) => e.eventType === 'Lecture')
    performanceList.value = allEvents.filter((e: EventDetail) => e.eventType === 'Performance' || e.eventType === 'Performances')
  } catch (error) {
    console.error('获取活动列表失败:', error)
  }
}

// 路由跳转
const goToDetail = (id: number) => {
  router.push(`/event/${id}`)
}

// 日期格式化
const formatTime = (timeStr: string) => {
  if (!timeStr) return ''
  return timeStr.replace('T', ' ').substring(0, 16)
}

onMounted(() => {
  fetchEvents()
})
</script>

<style scoped>
/* ================= 全局颜色变量 (基于大麦官方规范) ================= */
.home-container {
  --primary-red: #FF1268;
  --primary-orange: #FF5400;
  --bg-light: #F5F6F8;
  --text-primary: #1D2129;
  --text-secondary: #666666;
  --text-white: #FFFFFF;
  --border-light: #E5E6EB;
  
  background-color: var(--bg-light); /* 应用浅灰色底色 */
  min-height: 100vh;
  padding: 30px 20px;
}

/* ================= 头部区域 ================= */
.header-section {
  text-align: center;
  margin-bottom: 40px;
}

.main-title {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 12px;
  color: var(--primary-red);
  font-size: 2rem;
  margin: 0 0 10px 0;
}

.subtitle {
  color: var(--text-secondary);
  font-size: 1rem;
  margin: 0;
}

/* ================= 列表布局 ================= */
.columns-wrapper {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 30px;
  max-width: 1200px;
  margin: 0 auto;
}

.column-title {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 1.25rem;
  color: var(--text-primary);
  margin-bottom: 20px;
  font-weight: bold;
}

.section-icon {
  color: var(--primary-orange);
}

.event-list {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

/* ================= 大麦风极简卡片 ================= */
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

/* 点击状态：微微下陷缩小的点击反馈 */
.event-card:active {
  transform: translateY(-1px) scale(0.98);
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.04);
}

/* 主信息区 */
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

/* 修改点：改为水平排列，并且允许换行防重叠 */
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

/* 底部操作与状态区 */
.card-footer {
  display: flex;
  justify-content: space-between;
  align-items: flex-end;
  border-top: 1px dashed var(--border-light); /* 分割线稍微弱化为虚线更好看 */
  padding-top: 15px;
  position: relative;
  z-index: 1;
}

/* 修改点：将组织者改为胶囊形态 */
.pill-capsule {
  background-color: #FFF0F4; /* 极浅的红色背景 */
  color: var(--primary-red);
  padding: 4px 12px;
  border-radius: 999px; /* 极限圆角实现胶囊态 */
  font-size: 0.85rem;
  font-weight: bold;
}

.stock-container {
  display: flex;
  align-items: baseline;
  gap: 4px;
}

.stock-label {
  color: var(--text-secondary);
  font-size: 0.85rem;
}

/* 重点突出数字 */
.stock-number {
  font-size: 1.4rem;
  font-weight: bold;
  color: var(--primary-red); /* 默认大麦红 */
}

/* 库存紧张时变为活力橙 */
.low-stock {
  color: var(--primary-orange);
}

.empty-state {
  text-align: center;
  color: var(--text-secondary);
  padding: 40px 0;
  font-size: 0.95rem;
}

/* 移动端适配 */
@media (max-width: 768px) {
  .columns-wrapper {
    grid-template-columns: 1fr;
  }
}
</style>