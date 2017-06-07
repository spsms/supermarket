package com.softwareprocess.sms.service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.softwareprocess.sms.param.DataTableReceiveParam;
import com.softwareprocess.sms.persistence.FinanceMapper;
import com.softwareprocess.sms.tools.MapUtil;

@Service
public class FinanceService {
	@Autowired
	FinanceMapper financeMapper;

	public List<Map<String, Object>> getSalary(HttpServletRequest request) {
		Map<String, Object> param = new HashMap<String, Object>();
		new DataTableReceiveParam(request).setDatabaseQuery(param);
		return financeMapper.getSalary(param);
	}

	public List<Map<String, Object>> getProfit(HttpServletRequest request, String beginTime, String endTime) {
		Map<String, Object> param = new HashMap<>();
		new DataTableReceiveParam(request).setDatabaseQuery(param);
		MapUtil.putMapParaEmpty(param, "beginTime", beginTime);
		MapUtil.putMapParaEmpty(param, "endTime", endTime);
		List<Map<String, Object>> result = financeMapper.getProfit(param);
		
		return result;
	}

}
