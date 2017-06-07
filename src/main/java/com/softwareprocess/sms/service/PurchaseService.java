package com.softwareprocess.sms.service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.softwareprocess.sms.param.DataTableReceiveParam;
import com.softwareprocess.sms.persistence.PurchaseMapper;
import com.softwareprocess.sms.tools.MapUtil;

@Service
public class PurchaseService {
	@Autowired
	PurchaseMapper purchaseMapper;

	public List<Map<String, Object>> getGoodStockList(HttpServletRequest request) {
		Map<String, Object> param = new HashMap<String, Object>();
		new DataTableReceiveParam(request).setDatabaseQuery(param);
		return purchaseMapper.getGoodStockList(param);
	}

	public List<Map<String, Object>> getRestockRecordList(HttpServletRequest request) {
		Map<String, Object> param = new HashMap<String, Object>();
		new DataTableReceiveParam(request).setDatabaseQuery(param);
		return purchaseMapper.getRestockRecordList(param);
	}

	public List<Map<String, Object>> getProviderList(HttpServletRequest request, String pname) {
		Map<String, Object> param = new HashMap<>();
		new DataTableReceiveParam(request).setDatabaseQuery(param);
		MapUtil.putMapParaEmpty(param, "name", pname);
		return purchaseMapper.getProviderList(param);
	}

	public List<Map<String, Object>> getProviderNameList(HttpServletRequest request) {
		Map<String, Object> param = new HashMap<>();
		return purchaseMapper.getProviderNameList(param);
	}

}
