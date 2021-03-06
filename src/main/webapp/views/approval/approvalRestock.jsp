<%@ page language="java" import="java.util.*" pageEncoding="utf-8"
	isELIgnored="true"%>
<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c"%>

<!DOCTYPE html>
<html>
<head>
<%@include file="../resources.jsp"%>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<script type="text/javascript"
	src="<c:url value="/resources/js/jquery.md5.js"/>"></script>
<title></title>
</head>
<body>
	<div class="panel panel-success"
		style="padding: 0px; border: 0px; border-bottom: 0px; margin: 10px;">
		<div class="panel-body" style="background-color: #FFF;">
			<form class="form1 form-inline" id="searchForm">
				<div class="form-group">
					<label>审核状态</label> <select class="form-control" name="status"
						style="width: 120px">
						<option value="" selected="selected">全部</option>
						<option value="0">待审核</option>
						<option value="2">否决</option>
						<option value="1">通过</option>
					</select>
				</div>
				<div class="form-group">
					<button type="button" onclick="reloadData()"
						class="btn btn-primary">查询</button>
				</div>
			</form>
		</div>
		<table id="dataTable" style="text-align: center;" class="display"
			cellspacing="0"></table>
	</div>

<div class="modal fade" id="addTempBox" tabindex="-1" role="dialog"
     aria-labelledby="myModalLabel" aria-hidden="true">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
               <button type="button" class="close" data-dismiss="modal"
                        aria-hidden="true">×</button><h4 class="modal-title" id="myModalLabel">进货审批</h4>
            </div>
            <div style="width: 90%;margin: 10px auto;">
                <form class="form-horizontal" id="addBoxForm">
	                <div class="form-group">
							<label class="col-sm-2 control-label">审核：</label>
							<div class="col-sm-10">
								<select class="DataInput" name="checkMark" id="checkMark">
									<option value="0" selected="selected">待审核</option>
									<option value="2">否决</option>
									<option value="1">通过</option>
								</select>
							</div>
						</div>
						<div class="form-group">
							<label class="col-sm-2 control-label">审核意见</label>
							<div class="col-sm-10">
								<input type="text" class="DataInput form-control" id="remark">
							</div>
						</div>
	                <div class="form-group" style="display: none">
							<label class="col-sm-2 control-label">id</label>
							<div class="col-sm-10">
								<input type="text" class="DataInput form-control" id="rid">
							</div>
					</div>
                </form>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
                <button type="button" class="btn btn-primary" onclick="submitAddBoxData()">提交</button>
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
            minView:"month",
            format: "yyyy-mm-dd",//显示格式
            todayBtn: true,//当前日期的按钮
            todayHighlight:true,//当前日前是否高亮
            language:'zh-CN', //语言选择
            autoclose: true //关闭时间的选择
        });
    });

    var dataTableConfig = {
        "ajax": {
            "url": "<c:url value="/approval/getApprovalRestockList"/>?fresh=" + Math.random(),
            "type": "post",
            "data": function (d){
                setFormDataInObject($('#searchForm'),d);
            }
        },
        "columns": [{
            "title": "进货员工账户",
            "data": "eid"
        }, {
            "title": "进货员工姓名",
            "data": "ename"
        }, {
            "title": "申请时间",
            "data": "rdate"
        }, {
            "title": "进货批次",
            "data": "rbatch"
        }, {
            "title": "供货商",
            "data": "pname"
        }, {
            "title": "预计利润",
            "data": "rprofit"
        },{
            "title": "文件下载",
            "data": null
        }, {
            "title": "审核状态",
            "data": "status"
        }, {
            "title" : "审核",
            "data" : null
        }],
        "columnDefs": [
        	{
                "render" : function(data, type, row, meta){
                	if(data == "0") {
                        return "未审核";
                    }
                	else if(data == "1") {
                    	return "已通过";
                    }
                	else if(data == "2") {
                    	return "未通过";
                    }else{
                    	return data;
                    }
                },
                "targets" : 7
            },
            {
                "render" : function(data, type, row, meta){
                    return '<button type="button" onclick="addTemp(\''+data.rid+'\')" class="btn btn-primary">审核</button>';
                },
                "targets" : 8
            },
            {
                "render" : function(data, type, row, meta){
                	return '<a href="<c:url value="/approval/downloadApprovalFile"/>?filePath=\''+data.filePath+'\'">下载</a>';
                	//return '<button type="button" onclick="download(\''+data.filePath+'\')" class="btn btn-primary"></button>';
                },
                "targets" : 6
            },
            {
                "render" : function(data, type, row, meta){
                    if(typeof data == "undefined") {
                        return ''
                    }
                    return data;
                },
                "targets" : [0,1,2,3,4,5,6,7,8]
            }
        ]
    };

    var datatablesData;//当前页查询数据缓存
    /**
     * 加载数据
     */
    function loadData() {
        datatable = $('#dataTable')
            .on('init.dt', function (){
                datatablesData = datatable.data();
            })
            .DataTable(dataTableConfig);
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
    function addTemp(rid) {
    	//console.log("rid"+rid);
    	$("#rid").val(rid);
    	$("#remark").val("");
        $('#addTempBox').modal({});
    }

    /**
     * 审批提交
     */
    function submitAddBoxData() {
    	console.log($('#rid').val());
        var data = {
        		"rid":$("#rid").val(),
        		"remark":$("#remark").val(),
        		"status":$('#checkMark option:selected').val()
        }
        console.log(data);
        $.ajax({
            type : "post",
            url : "<c:url value="/approval/approvalRestock"/>",
            dataType : "json",
            data : data,
            contentType: "application/x-www-form-urlencoded; charset=utf-8",
            success : function(data) {
            	//console.log(data);
                if(data == 'success') {
                    swal("提示", "提交成功!", "success")
                    reloadData();
                    $('#addTempBox').modal('hide');
                } else {
                    swal("提示","提交失败，请重试!");
                }
            }
        });
    }

</script>
</body>
</html>
