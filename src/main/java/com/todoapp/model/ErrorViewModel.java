package com.todoapp.model;

/**
 * Error view model for error handling
 * Equivalent to ErrorViewModel.cs in the original ASP.NET Core application
 */
public class ErrorViewModel {
    
    private String requestId;
    
    public ErrorViewModel() {}
    
    public ErrorViewModel(String requestId) {
        this.requestId = requestId;
    }
    
    public String getRequestId() {
        return requestId;
    }
    
    public void setRequestId(String requestId) {
        this.requestId = requestId;
    }
    
    public boolean isShowRequestId() {
        return requestId != null && !requestId.trim().isEmpty();
    }
    
    public boolean getShowRequestId() {
        return isShowRequestId();
    }
}
