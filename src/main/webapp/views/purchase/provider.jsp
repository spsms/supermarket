<%@ page language="java" contentType="text/html; charset=utf-8"
	pageEncoding="utf-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<%@include file="../resources.jsp"%>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<script type="text/javascript"
	src="<c:url value="/resources/js/jquery.md5.js"/>"></script>
<link href="<c:url value="/resources/css/saleMain.css"/>"
	rel="stylesheet" type="text/css" media="screen" />
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<script type="text/javascript">
	$(function() {
		$
				.ajax({
					type : "post",
					url : "<c:url value="/sale/getGoodKindList"/>",
					dataType : "json",
					data : {},
					contentType : "application/x-www-form-urlencoded; charset=utf-8",
					success : function(data) {
						for (var i = 0; i < data.length; i++) {
							var item = data[i]
							var check = 'unchecked';
							var $radio = $('<input type="checkbox" autocomplete="off" class="goodKind" value = "'+item.gkid+'"  '+check+'> '
									+ item.gkname + '</input>');
							$("#typeRadio").append($radio);
						}
					}
				});
	});
</script>
<title>供应商信息管理</title>
</head>
<body>
	<div class="panel panel-success"
		style="padding: 0px; border: 0px; border-bottom: 0px; margin: 10px;">
		<div class="panel-body" style="background-color: #FFF;">
			<form class="form1 form-inline" id="searchForm">
				<div class="form-group">
					<label>供应商名称</label> <input type="text" class="form-control"
						name="account" style="width: 120px">
				</div>
				<div class="form-group">
					<button type="button" onclick="reloadData()"
						class="btn btn-primary">查询</button>
				</div>
				<div class="form-group">
					<button type="button" onclick="addTemp()" class="btn btn-primary">新增</button>
				</div>
			</form>
		</div>
		<table id="dataTable" style="text-align: center; " class="display"
			cellspacing="0"></table>
	</div>


	<!-- 新增模态框 -->
	<div class="modal fade" id="addTempBox" tabindex="-1" role="dialog"
		aria-labelledby="myModalLabel" aria-hidden="true">
		<div class="modal-dialog">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal"
						aria-hidden="true">×</button>
					<h4 class="modal-title" id="myModalLabel">新增供应商信息</h4>
				</div>
				<div style="width: 90%; margin: 10px auto;">
					<form class="form-horizontal" id="addBoxForm">
						<div class="form-group" style="display: none">
							<label class="col-sm-2 control-label">id</label>
							<div class="col-sm-10">
								<input type="text" class="DataInput form-control" name="pid">
							</div>
						</div>
						<div class="form-group">
							<label class="col-sm-2 control-label">供应商名称</label>
							<div class="col-sm-10">
								<input type="text" class="DataInput form-control" name="pname"
									required>
							</div>
						</div>

						<div class="form-group">
							<label class="col-sm-2 control-label">联系方式</label>
							<div class="col-sm-10">
								<input type="text" class="DataInput form-control"
									name="pcontact" required>
							</div>
						</div>
						<div class="form-group">
							<label class="col-sm-2 control-label">地址</label>
							<div class="col-sm-10">
								<input type="text" class="DataInput form-control"
									name="paddress" required>
							</div>
						</div>
						<div class="form-group">
							<label class="col-sm-2 control-label">商品种类</label>
							<div class="col-sm-10">
								<div class="btn-group" id="typeRadio">
									<%--程序填充--%>
								</div>
							</div>
						</div>
					</form>
				</div>
				<div class="modal-footer">
					<button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
					<button type="button" class="btn btn-primary"
						onclick="submitAddBoxData()">保存</button>
				</div>
			</div>
		</div>
	</div>

	<script type="text/javascript">
		var datatable;
		$(document).ready(function() {
			dataTablesServerSideInit();
			loadData();
			//日期选择初始化
			$(".formDatetime").datetimepicker({
				minView : "month",
				format : "yyyy-mm-dd",//显示格式
				todayBtn : true,//当前日期的按钮
				todayHighlight : true,//当前日前是否高亮
				language : 'zh-CN', //语言选择
				autoclose : true
			//关闭时间的选择
			});
		});

		var dataTableConfig = {
			"ajax" : {
				"url" : "<c:url value="/purchase/getProviderList"/>?fresh="
						+ Math.random(),
				"type" : "post",
				"data" : function(d) {
					setFormDataInObject($('#searchForm'), d);
				}
			},
			"columns" : [ {
				"title" : "名称",
				"data" : "pname"
			}, {
				"title" : "联系方式",
				"data" : "pcontact"
			}, {
				"title" : "地址",
				"data" : "paddress"
			}, {
				"title" : "商品类型",
				"data" : "goodkind"
			}, {
				"title" : "操作",
				"data" : null
			} ],
			"columnDefs" : [
					{
						"render" : function(data, type, row, meta) {
							var button = '<button type="button" onclick="addTemp(\''
									+ data.pid
									+ '\')" class="btn btn-primary">修改</button> <button type="button" onclick="deleteListData(\''
									+ data.pid
									+ '\')" class="btn btn-danger">删除</button> ';
							return button;
						},
						"targets" : 4
					}, {
						"render" : function(data, type, row, meta) {
							if (typeof data == "undefined") {
								return ''
							}
							return data;
						},
						"targets" : [ 0, 1, 2, 3 ]
					}

			]
		};

		var datatablesData;//当前页查询数据缓存
		/**
		 * 加载数据
		 */
		function loadData() {
			console.log("加载数据");
			datatable = $('#dataTable').on('init.dt', function() {
				datatablesData = datatable.data();
			}).DataTable(dataTableConfig);
		}

		/**
		 * 重新加载数据
		 */
		function reloadData() {

			datatable.destroy();
			loadData();
		}

		/**
		 * 打开新增编辑框
		 */
		function addTemp(pid) {
			setFormDataEmpty($("#addBoxForm"));//清空现有表单
			$('#addTempBox').modal({});
			var dataObj = getDataObjFromArray(datatablesData, "pid", pid);
			//console.log(dataObj);
			setFormDataFromObj($("#addBoxForm"), dataObj);
		}

		/**
		 * 删除数据
		 * @param id
		 */

		function deleteListData(pid) {
			swal(
					{
						title : "确认删除?",
						text : "您将删除该用户!",
						type : "warning",
						showCancelButton : true,
						confirmButtonColor : "#DD6B55",
						confirmButtonText : "删除!",
						closeOnConfirm : false
					},
					function() {
						$.ajax({
									type : "post",
									url : "<c:url value="/purchase/deleteProvider"/>",
									dataType : "json",
									data : {
										pid : pid
									},
									contentType : "application/x-www-form-urlencoded; charset=utf-8",
									success : function(data) {
										data = $.trim(data);
										//console.log(data);
										if (data == 'success') {
											swal("提示", "操作成功!", "success")
											reloadData();
											$('#addTempBox').modal('hide');
										} else if (data == 'authorityError') {
											swal("您没有此权限!");
											$('#addTempBox').modal('hide');
										} else {
											swal("删除失败，请重试!");
										}
									}
								});

					});
		}

		/**
		 * 提交用户编辑框数据
		 */

		function submitAddBoxData() {
			//校验
			var pid = '';
			if ($("#addBoxForm").validate().form()) {
				var mdata = {};
				var goodKindList = '';
				setFormDataInObject($("#addBoxForm"), mdata);
				var obj = $($("#typeRadio").children(".goodKind"));
				var j = 0;
				for (var i = 0; i < obj.length; i++) {
					if (obj[i].checked) {
						if (j == 0) {
							goodKindList = obj[i].value;
							//console.log("进入i=0");
						} else {
							goodKindList += ("," + obj[i].value);
						}
						j++;
					}
				}
				//console.log(goodKindList);
				mdata.pgoodkindList = goodKindList;
				//console.log(mdata);
				pid = $("input[name='pid']").val();
				var murl = '';
				if (pid == '') {
					console.log("pid为空")
					murl = "<c:url value="/purchase/addProvider"/>";
				} else {
					murl = "<c:url value="/purchase/updateProvider"/>";
				}
				console.log(murl);
				$.ajax({
							type : "post",
							url : murl,
							dataType : "json",
							data : mdata,
							contentType : "application/x-www-form-urlencoded; charset=utf-8",
							success : function(data) {
								data = $.trim(data);
								console.log(data);
								if (data == 'success') {
									swal("提示", "操作成功!", "success")
									reloadData();
									$('#addTempBox').modal('hide');
								} else if (data == 'providerError') {
									swal("您没有此权限!");
								} else {
									swal("删除失败，请重试!");
								}
							}
						});
			}
		}
	</script>

</body>
</html>