<%@ page language="java" contentType="text/html; charset=utf-8"
	pageEncoding="utf-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<%@include file="../resources.jsp"%>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<script type="text/javascript"
	src="<c:url value="/resources/js/jquery.md5.js"/>"></script>
<link href="<c:url value="/resources/css/purchaseMain.css"/>"
	rel="stylesheet" type="text/css" media="screen" />
<title></title>
</head>
<body>
	<div class="panel-body" style="background-color: #FFF;">
		<form class="form1 form-inline" id="searchForm">
			<div class="form-group">
				<label>商品库存表</label>
			</div>
		</form>
	</div>
	<table id="dataTable" style="text-align: center;" class="display"
		cellspacing="0"></table>
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
				"url" : "<c:url value="/purchase/getGoodStockList"/>?fresh="
						+ Math.random(),
				"type" : "post",
				"data" : function(d) {
					setFormDataInObject($('#searchForm'), d);
				}
			},
			"columns" : [ {
				"title" : "商品名称",
				"data" : "gname"
			}, {
				"title" : "商品种类",
				"data" : "gkind"
			}, {
				"title" : "商品库存",
				"data" : "gstock"
			}, {
				"title" : "生产日期",
				"data" : "pddate"
			}, {
				"title" : "保质期",
				"data" : "keepdate"
			}, {
				"title" : "售价",
				"data" : "gprice"
			}, {
				"title" : "商品销售量（当月）",
				"data" : "scount"
			}, {
				"title" : "商品退货记录",
				"data" : "brid"
			} ],
			"columnDefs" : [
					{
						"render" : function(data, type, row, meta) {
							if (typeof data == "undefined") {
								return '无'
							} else {
								return  '<button type="button" onclick="addTemp(\''
										+ data.brid
										+ '\')" class="btn btn-primary">退货详情</button>';
							}
						},
						"targets" : [ 7 ]
					}, {
						"render" : function(data, type, row, meta) {
							if (typeof data == "undefined") {
								return '0'
							}
							return data;
						},
						"targets" : [ 2, 5, 6 ]
					}, {
						"render" : function(data, type, row, meta) {
							if (typeof data == "undefined") {
								return ''
							}else{
								return data;
							}
						},
						"targets" : [ 0, 1, 2, 3, 4, 5, 6, 7 ]
					} ]
		};

		var datatablesData;//当前页查询数据缓存
		/**
		 * 加载数据
		 */
		function loadData() {
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

		function addTemp(snumber) {
			$.ajax({
						type : "post",
						url : "<c:url value="/purchase/getBackDetail"/>",
						dataType : "json",
						data : {
							brid : brid
						},
						contentType : "application/x-www-form-urlencoded; charset=utf-8",
						success : function(mdata) {
							var j = 1;
							var detail = "  " + ":订单编号" + "	" + "退货数量" + "		"
									+ "退货日期" + "			" + "备注" + "\r\n";
							var money = 0;
							for (var i = 0; i < mdata.length; i++) {
								var item = j + ","
								mdata[i].brnumber + "   	" + mdata[i].scount
										+ "        		" + mdata[i].brdate
										+ "       		" + mdata[i].brremark
										+ "\r\n";
								detail += item;
								j++;
								money = Number(money) + Number(mdata[i].money);
							}
							$("#back_gname").val(mdata[0].gname);
							$("#back_detail").val(detail);
							$('#saleDetailBox').modal({});
						},
						error : function(mdata) {
							console.log("shibai" + mdata);
						}
					});
		}
	</script>

	<!-- 退货模态框 -->
	<div class="modal fade" id="backDetailBox" tabindex="-1" role="dialog"
		aria-labelledby="myModalLabel" aria-hidden="true">
		<div class="modal-dialog">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal"
						aria-hidden="true">×</button>
					<h4 class="modal-title" id="myModalLabel">退货详情</h4>
				</div>
				<div style="width: 90%; margin: 10px auto;">
					<form class="form-horizontal" id="confirmSaleBoxForm">
						<div class="form-group">
							<label class="col-sm-2 control-label">退货商品</label>
							<div class="col-sm-10">
								<input type="text" class="DataInput form-control"
									id="back_gname">
							</div>
						</div>

						<div class="form-group">
							<label class="col-sm-2 control-label">退货详情</label>
							<div class="col-sm-10">
								<textarea style="height: 80px" type="text"
									class="DataInput form-control" id="back_detail"></textarea>
							</div>
						</div>
					</form>
				</div>
				<div class="modal-footer">
					<button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
				</div>
			</div>
		</div>
	</div>

</body>
</html>