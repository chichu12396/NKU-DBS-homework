package com.study.controller;

import com.study.entity.Result;
import com.study.entity.TicketDTO;
import com.study.service.TicketService;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/ticket")
public class TicketController {

    @Autowired
    private TicketService ticketService;

    // 购票接口
    // 前端访问：POST http://localhost:8080/ticket/buy
    @PostMapping("/buy")
    public Result<String> buyTicket(@RequestParam Integer userId, @RequestParam Integer eventId) {
        // 调用 Service 层拿到存储过程返回的状态
        String status = ticketService.buyTicket(userId, eventId);
        
        if ("Success".equals(status)) {
            return Result.success("购票成功！您的订单已生成。");
        } else if ("Sold Out".equals(status)) {
            return Result.error("手慢啦，该活动门票已售罄！");
        } else {
            return Result.error("购票失败，系统异常：" + status);
        }
    }

    // 退票接口
    // 前端访问：POST http://localhost:8080/ticket/refund
    @PostMapping("/refund")
    public Result<String> refundTicket(@RequestParam Integer orderId) {
        String status = ticketService.refundTicket(orderId);
        
        if ("Refund Success".equals(status)) {
            return Result.success("退票成功！票款将原路返回。");
        } else if ("Event Ended".equals(status)) {
            return Result.error("退票失败：该演出已经结束！");
        } else if ("Wrong Status".equals(status)) {
            return Result.error("退票失败：订单状态异常（可能未支付或已退款）！");
        } else if ("Order Not Found".equals(status)) {
            return Result.error("退票失败：找不到该订单！");
        } else {
            return Result.error("系统异常：" + status);
        }
    }
 // 获取我的票夹
    @GetMapping("/my")
    public Result<List<TicketDTO>> getMyTickets(@RequestParam Integer userId) { // 🎯 改成这样接收
        List<TicketDTO> list = ticketService.getMyTickets(userId);
        return Result.success(list);
    }
}