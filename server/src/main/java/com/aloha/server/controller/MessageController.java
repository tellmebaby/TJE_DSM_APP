package com.aloha.server.controller;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.security.core.annotation.AuthenticationPrincipal;

import com.aloha.server.service.FileService;
import com.aloha.server.dto.Message;
import com.aloha.server.service.MessageService;
import com.aloha.server.dto.CustomUser;
import com.aloha.server.dto.Users;

import lombok.extern.slf4j.Slf4j;

@Slf4j
@CrossOrigin(origins = "*")
@RestController
@RequestMapping("/message")
public class MessageController {

    @Autowired
    private MessageService messageService;

    @Autowired
    private FileService fileService;

    // @PostMapping("/insertToAdmin")
    // public ResponseEntity<String> insertPro(@RequestBody Message messageDTO, 
    //                                         @RequestParam Integer userNo) {

    //     String name = messageDTO.getName();

    //     if (name != "관리자" && name == null) {

    //         if (userNo == null) {
    //             return ResponseEntity.status(401).body("User not authenticated");
    //         }

    //         if (messageDTO.getContent() == null || messageDTO.getContent().isEmpty()) {
    //             return ResponseEntity.status(400).body("Content cannot be null or empty");
    //         }

    //     } else {
    //         userNo = messageDTO.getUserNo();
    //     }

    //     if (userNo == 0) {
    //         return ResponseEntity.status(401).body("User not authenticated");
    //     }

    //     Message message = new Message();
    //     message.setContent(messageDTO.getContent());
    //     message.setCode(messageDTO.getCode());
    //     message.setPayNo(0);
    //     message.setQnaNo(0);
    //     message.setReplyNo(0);
    //     message.setUserNo(userNo);

    //     int result = messageService.insertMessage(message);
    //     if (result > 0) {
    //         log.info("Insert successful!");
    //         return ResponseEntity.ok("Message saved successfully");
    //     }
    //     return ResponseEntity.status(500).body("Failed to save message");
    // }

    @PostMapping("/insertToAdmin")
public ResponseEntity<String> insertPro(@RequestBody Message messageDTO, @RequestParam(required = true) Integer userNo) {

    String name = messageDTO.getName();
    if (name == null || !"관리자".equals(name)) {
        if (userNo == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("User not authenticated");
        }

        if (messageDTO.getContent() == null || messageDTO.getContent().isEmpty()) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("Content cannot be null or empty");
        }
    } else {
        userNo = messageDTO.getUserNo();
    }

    if (userNo == 0) {
        return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("User not authenticated");
    }

    Message message = new Message();
    message.setContent(messageDTO.getContent());
    message.setCode(messageDTO.getCode());
    message.setPayNo(0);
    message.setQnaNo(0);
    message.setReplyNo(0);
    message.setUserNo(userNo);

    int result = messageService.insertMessage(message);
    if (result > 0) {
        return ResponseEntity.ok("Message saved successfully");
    }
    return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("Failed to save message");
}

    

    @GetMapping("/{messageNo}")
    public ResponseEntity<?> getMessage(@PathVariable int messageNo) {
        try {
            Message message = messageService.getMessageById(messageNo);
            return new ResponseEntity<>(message, HttpStatus.OK);
        } catch (Exception e) {
            return new ResponseEntity<>("FAIL", HttpStatus.BAD_REQUEST);
        }
        
    }

    @PutMapping("/")
    public void updateMessage(@RequestBody Message messageDTO) {
        messageService.updateMessage(messageDTO);
    }

    @DeleteMapping("/{messageNo}")
    public void deleteMessage(@PathVariable int messageNo) {
        messageService.deleteMessage(messageNo);
    }

    @GetMapping("/getChatMessagesByUser")
    public ResponseEntity<List<Message>> getMessagesByUser(@RequestParam("userNo") Integer userNo) {
        
        if ( userNo == 0) {
            return ResponseEntity.status(401).build();
        }
        List<Message> messages = messageService.getChatMessageByUser(userNo);
        return ResponseEntity.ok(messages);
    }

    @PostMapping("/MessagesList")
    public ResponseEntity<List<Message>> messagesList() throws Exception {
        List<Message> messagesList = messageService.getMessagesList();
        for (Message message : messagesList) {
            Integer fileNo = fileService.profileSelect(message.getUserNo());
            message.setImgNo(fileNo);
        }
        return ResponseEntity.ok(messagesList);
    }

    @PostMapping("/getMessagesByUser")
    public ResponseEntity<List<Message>> userChatList(int no) throws Exception {
        List<Message> messagesList = messageService.getMessageByUser(no);
        messageService.updateView(no, "toAdmin");

        for (Message message : messagesList) {
            Integer fileNo = fileService.profileSelect(message.getUserNo());
            message.setImgNo(fileNo);
        }
        return ResponseEntity.ok(messagesList);
    }

    
    @GetMapping("/messageClose")
    public ResponseEntity<?> closeMessage(@AuthenticationPrincipal CustomUser customUser) {
        Users user = customUser.getUser();
        if (user != null) {
            int result = messageService.updateMessageByUser(user.getUserNo());
            if (result > 0) {
                log.info("대화종료 성공");
                return ResponseEntity.noContent().build(); // HTTP 204 No Content
            } else {
                log.info("메세지 코드 수정 실패");
                // 여기서 접근 거부 오류를 반환하는 경우
                throw new AccessDeniedException("메세지 코드 수정 실패");
            }
        }
        throw new AccessDeniedException("유저 정보 없음");
        // return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("유저 정보 없음");
    }

    
}
