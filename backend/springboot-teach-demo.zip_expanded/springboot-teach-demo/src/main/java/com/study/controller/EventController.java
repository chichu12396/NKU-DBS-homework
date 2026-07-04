package com.study.controller;
import com.study.entity.Event;
import com.study.entity.EventDetailsDTO;
import com.study.entity.Result;
import com.study.service.EventService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/event")
public class EventController {

    @Autowired
    private EventService eventService;

    // 获取首页活动列表接口
    // 前端访问：GET http://localhost:8080/event/list
    @GetMapping("/list")
    public Result<List<EventDetailsDTO>> getAvailableEvents() {
        List<EventDetailsDTO> list = eventService.getAvailableEvents();
        return Result.success(list);
    }

    // 结算活动接口
    // 前端访问：POST http://localhost:8080/event/complete
    @PostMapping("/complete")
    public Result<String> completeEventTickets(@RequestParam Integer eventId) {
        try {
            Integer affectedRows = eventService.completeEventTickets(eventId);
            return Result.success("结算成功，共更新了 " + affectedRows + " 条订单状态。");
        } catch (Exception e) {
            // 捕获我们在存储过程里抛出的 SIGNAL 异常（"该活动尚未结束"）
            return Result.error("结算失败：" + e.getMessage());
        }
    }
    @PostMapping("/add")
    public Result<String> addEvent(@RequestBody Event event) {
        boolean success = eventService.addEvent(event);
        if (success) {
            return Result.success("活动发布成功！");
        } else {
            return Result.error("活动发布失败，请检查填写的信息。");
        }
    }

    //删除活动接口
    // 前端访问：POST http://localhost:8080/event/delete
    @PostMapping("/delete")
    public Result<String> deleteEvent(@RequestParam Integer eventId) {
        try {
            boolean success = eventService.removeEvent(eventId);
            if (success) {
                return Result.success("活动已成功下架删除！");
            } else {
                return Result.error("删除失败：找不到该活动ID。");
            }
        } catch (Exception e) {
            // 这里通常会捕捉到外键约束报错，比如这个活动已经有订单了，就不能硬删
            return Result.error("删除失败：该活动可能已有用户购票关联记录。");
        }
    }
    @GetMapping("/detail")
    public Result<EventDetailsDTO> getEventDetail(@RequestParam Integer eventId) {
        EventDetailsDTO detail = eventService.getEventDetailById(eventId);
        return Result.success(detail);
    }
}