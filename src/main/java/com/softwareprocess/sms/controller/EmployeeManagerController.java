package com.softwareprocess.sms.controller;

import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.annotation.Resource;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import com.softwareprocess.sms.param.DataTableSendParam;
import com.softwareprocess.sms.service.CommonDatabaseService;
import com.softwareprocess.sms.service.EmployeeManagerService;
import com.softwareprocess.sms.tools.IDBuilder;
import com.softwareprocess.sms.tools.JsonUtil;

//员工管理模块
@Controller
@RequestMapping(value = "manager")
public class EmployeeManagerController {

	@Resource
	private EmployeeManagerService employeeManagerService;

	@Resource
	private CommonDatabaseService commonDatabaseService;

	private IDBuilder idBuilder = new IDBuilder();

	/**
	 * 获取员工列表
	 * 
	 * @param request
	 * @param name  模糊查询
	 * @param account  精确查询
	 * @return
	 */
	@ResponseBody
	@RequestMapping(value = "getEmployeeList", produces = "application/json; charset=utf-8")
	public String getEmployeeList(HttpServletRequest request,
			@RequestParam(value = "name", required = false) String name,
			@RequestParam(value = "account", required = false) String account) {
		System.out.println(name);
		List<Map<String, Object>> resultCount = employeeManagerService.getEmployeeList(null, name, account);
		List<Map<String, Object>> result = employeeManagerService.getEmployeeList(request, name, account);
		return new DataTableSendParam(resultCount.get(0).get("sum"), resultCount.get(0).get("sum"), result).toJSON();
	}

	/**
	 * 获取可操作权限列表 用户只能操作比自己拥有的最高权限等级低的权限
	 * 
	 * @return
	 */
	@ResponseBody
	@RequestMapping(value = "getOperateAuthority", produces = "application/json; charset=utf-8")
	public String getOperateAuthority(HttpServletRequest request) {
		if (!confirmAuthority(request)) {
			return "authorityError";
		}
		HttpSession session = request.getSession();
		String userID = session.getAttribute("userID").toString();
		// String userID = "e-1705071022274399";
		List<Map<String, Object>> result = employeeManagerService.getOperateAuthority(userID);
		return JsonUtil.toJSON(result);
	}

	/**
	 * 添加员工 写入员工基本信息，并添加权限
	 * 
	 * @param request
	 * @param name
	 *            员工姓名
	 * @param account
	 *            员工账户
	 * @param password
	 *            员工密码
	 * @param salary
	 *            员工基本工资
	 * @param authorityList
	 *            权限ID列表，多项逗号隔开
	 * @return
	 */
	@ResponseBody
	@RequestMapping(value = "addEmployee", produces = "application/json; charset=utf-8")
	public String addEmployee(HttpServletRequest request, @RequestParam(value = "ename") String ename,
			@RequestParam(value = "eaccount") String eaccount, @RequestParam(value = "epassword") String epassword,
			@RequestParam(value = "esalary") String esalary, @RequestParam(value = "ehiredate") String ehiredate,
			@RequestParam(value = "eauthorityIDList") String eauthorityIDList) {
		if (!confirmAuthority(request)) {
			return "authorityError";
		}
		String resultCode = "error";
		String eid = idBuilder.getEmployeeID();
		Map<String, Object> param = new HashMap<String, Object>();
		param.put("ename", ename);
		param.put("eid", eid);
		param.put("eaccount", eaccount);
		param.put("epassword", epassword);
		param.put("esalary", esalary);
		if (ehiredate.equals("")) {
			Date time = new java.sql.Date(new java.util.Date().getTime());
			param.put("ehiredate", time);
		} else {
			param.put("ehiredate", ehiredate);
		}
		// System.out.println("员工姓名："+ename);
		int update = commonDatabaseService.insertStringData("employee", param);
		if (update > 0) {
			String[] authorityIDIItem = eauthorityIDList.split(",");
			List<Map<String, Object>> authorityParam = new ArrayList<Map<String, Object>>();
			for (int i = 0; i < authorityIDIItem.length; i++) {
				Map<String, Object> item = new HashMap<>();
				item.put("aid", authorityIDIItem[i]);
				item.put("eid", eid);
				authorityParam.add(item);
			}
			// int ist = commonDatabaseService.insertStringData(table, data)
			int insert = commonDatabaseService.insertStringDatas("e_a_relation", authorityParam);
			if (insert > 0) {
				resultCode = "success";
			}
		}
		return JsonUtil.toJSON(resultCode);
	}

	/**
	 * 删除员工
	 * 
	 * @param request
	 * @param eid
	 *            员工ID
	 * @return
	 */
	@ResponseBody
	@RequestMapping(value = "deleteEmployee", produces = "application/json; charset=utf-8")
	public String deleteEmployee(HttpServletRequest request, @RequestParam(value = "eid") String eid) {
		String resultCode = "error";
		if (!confirmAuthority(request)) {
			resultCode = "authorityError";
		} else if (eid.equals("1")) {
			resultCode = "authorityError";
		} else {
			int delete = commonDatabaseService.deleteSingleData("employee", "eid", eid);
			if (delete > 0) {
				resultCode = "success";
			}
		}

		return JsonUtil.toJSON(resultCode);
	}

	/**
	 * 修改员工信息
	 * 
	 * @param request
	 * @param name
	 *            员工姓名
	 * @param account
	 *            员工账户
	 * @param password
	 *            员工密码
	 * @param salary
	 *            员工基本工资
	 * @param authorityIDList
	 *            员工权限列表
	 * @return
	 */
	@ResponseBody
	@RequestMapping(value = "updateEmployee", produces = "application/json; charset=utf-8")
	public String updateEmployee(HttpServletRequest request, @RequestParam(value = "eid") String eid,
			@RequestParam(value = "ename", required = false) String ename,
			@RequestParam(value = "eaccount", required = false) String eaccount,
			@RequestParam(value = "epassword", required = false) String epassword,
			@RequestParam(value = "esalary", required = false) String esalary,
			@RequestParam(value = "ehiredate", required = false) String ehiredate,
			@RequestParam(value = "eauthorityIDList", required = false) String authorityIDList) {

		String resultCode = "error";
		if (!confirmAuthority(request)) {
			resultCode = "authorityError";
		} else if (eid.equals("1")) {
			resultCode = "authorityError";
		} else {
			System.out.println("ename" + ename);
			Map<String, Object> param = new HashMap<String, Object>();
			param.put("ename", ename);
			param.put("eaccount", eaccount);
			param.put("epassword", epassword);
			param.put("esalary", esalary);
			param.put("ehiredate", ehiredate);
			int update = commonDatabaseService.updateStringData("employee", "eid", eid, param);
			if (update > 0) {
				int delete = commonDatabaseService.deleteSingleData("e_a_relation", "eid", eid);
				if (delete > 0) {
					String[] authorityIDIItem = authorityIDList.split(",");
					List<Map<String, Object>> authorityParam = new ArrayList<Map<String, Object>>();
					for (int i = 0; i < authorityIDIItem.length; i++) {
						Map<String, Object> item = new HashMap<>();
						item.put("aid", authorityIDIItem[i]);
						item.put("eid", eid);
						authorityParam.add(item);
					}
					int insert = commonDatabaseService.insertStringDatas("e_a_relation", authorityParam);
					if (insert > 0) {
						resultCode = "success";
					}
				}
			}
		}
		return JsonUtil.toJSON(resultCode);
	}

	/**
	 * 验证用户是否有管理权限
	 * 
	 * @param request
	 * @return
	 */
	public boolean confirmAuthority(HttpServletRequest request) {
		HttpSession session = request.getSession();
		String AuthorityList = session.getAttribute("userAuthorityList").toString();
		if (AuthorityList.indexOf("管理") != -1) {
			return true;
		}
		return false;
	}

}
