<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/views/common/common.jsp"%>
<%@ include file="/WEB-INF/views/common/_head.jsp"%>

<script type="text/javascript" src="${staticPATH }/js/ztree/jquery.ztree.core.js"></script>
<script type="text/javascript" src="${staticPATH }/js/ztree/jquery.ztree.exedit.js"></script>
<script type="text/javascript" src="${staticPATH }/js/ztree/jquery.ztree.exhide.js"></script>

<!-- PAGE LEVEL STYLES -->
<link href="${staticPATH }/assets/css/layout2.css" rel="stylesheet" />
<link href="${staticPATH }/assets/plugins/flot/examples/examples.css" rel="stylesheet" />
<link rel="stylesheet" href="${staticPATH }/assets/plugins/timeline/timeline.css" />
<link rel="stylesheet" href="${staticPATH }/assets/css/zTreeStyle.css" type="text/css">
<link rel="stylesheet" href="${staticPATH }/assets/css/demo.css" type="text/css">

<link href="${staticPATH }/css/jquery_1.9.2/base/jquery-ui-1.9.2.custom.css" rel="stylesheet">
<script src="${staticPATH }/js/jquery_1.9.2/jquery-ui-1.9.2.custom.js"></script>
<!-- END PAGE LEVEL  STYLES -->

<!-- START SCRIPT -->
<script>
	var setting = {
		callback: {onClick: zTreeOnClick}
	};
	var zTree;
	var treeNodes;
	
	$(document).ready(function(){
		//달력 설정
		$("#RSRV_DT").datepicker({
			showOn: "button",
			buttonImage: "${staticPATH }/image/calendar.gif",
			buttonImageOnly: true,
			buttonText: "Select date"
		});
		
		//조회조건 선택시 이벤트 추가
		$("#SEARCH_TYPE").bind("change",fn_selectSearchType);
		//${staticServerType }
		
		jQuery.ajax({
			type          : 'POST',
			dataType      : "json",
			scriptCharset : "UTF-8",
			async         : true,
			url           : "${staticPATH }/campaignFolderList.do?serverType=${staticServerType }",
			success: function(result, option) {
				if (option == "success") {
					var list = result.CampaignFolder;
					//console.log(list);
					treeNodes = list;
					//$.fn.zTree.init($("#tree"), setting, treeNodes);
					var arrayVal = [];
					var prevVal = "";
					// 루트 디렉토리 최초 생성
					arrayVal.push(jsonDataSet("\\", "\\", "0"));
					$.each(list, function(key) {
						var data = list[key];
						var jsonData = new Object();
						//console.log("001 : " + data.campaign_folder_txt + " / " + data.cnt);
						var tmpTxt = data.campaign_folder_txt;
						var splitTmpTxt = tmpTxt.split("\\");
						var splitPrevTxt = "";
						
						if (prevVal != "") {  // 이전 항목이 존재 하면
							splitPrevTxt = prevVal.split("\\");
							//console.log("::::: " + splitTmpTxt.length + " / " + splitPrevTxt.length);
							if (splitTmpTxt.length > splitPrevTxt.length) { // 이전 항목보다 현재 항목이 더 큰경우
								//console.log("> ---- prevVal : " + prevVal + " ::: tmpTxt : " + tmpTxt + " ::: splitTmpTxt.length : " + splitTmpTxt.length);
								var pidData = splitPrevTxt[splitPrevTxt.length - 1];
							
								for(var i = 0; i < (splitTmpTxt.length - splitPrevTxt.length); i++) {
									//console.log("%%%" + splitTmpTxt[splitPrevTxt.length + i]);
									var id = splitTmpTxt[splitPrevTxt.length + i];
									var name = splitTmpTxt[splitPrevTxt.length + i];
									var pid = pidData;
									console.log("ADD 001 --- id : " + id + " name : " + name + " pid : " + pid);
									arrayVal.push(jsonDataSet(id, name, pid));
									pidData = splitTmpTxt[splitPrevTxt.length + i];
								}
							} else if (splitTmpTxt.length == splitPrevTxt.length) {
								//console.log("equals ---- prevVal : " + prevVal + " ::: tmpTxt : " + tmpTxt + " ::: splitTmpTxt.length : " + splitTmpTxt.length);
								// 최종 폴더명만 다른지 체크
								var chkFolderPath = fnChkFolderPath(splitTmpTxt, splitPrevTxt);
								
								// 최종 폴더명만 다르면
								if (chkFolderPath == (splitTmpTxt.length-1)) {
									var id = splitTmpTxt[splitTmpTxt.length-1];
									var name = splitTmpTxt[splitTmpTxt.length-1];
									var pid = splitTmpTxt[splitTmpTxt.length-2];
									// console.log("ADD 002 equal --- id : " + id + " name : " + name + " pid : " + pid);
									arrayVal.push(jsonDataSet(id, name, pid));
								} else {
									for(var i = chkFolderPath; i < splitTmpTxt.length ; i++) {
										var id = splitTmpTxt[i];
										var name = splitTmpTxt[i];
										var pid = 0;
										if (i > 0) {
											pid =  splitTmpTxt[i-1];
										}
										// console.log("ADD 003 --- id : " + id + " name : " + name + " pid : " + pid);
										if (id != "" && name != "") {
											arrayVal.push(jsonDataSet(id, name, pid));
										}
									}
								}
							} else if (splitTmpTxt.length < splitPrevTxt.length) {
								//console.log(" < ---- prevVal : " + prevVal + " ::: tmpTxt : " + tmpTxt);
								var chkFolderPath = fnChkFolderPath(splitTmpTxt, splitPrevTxt);
							
								if (chkFolderPath > 0) {
									for (var i = chkFolderPath; i < splitTmpTxt.length ; i++) {
										var id = splitTmpTxt[i];
										var name = splitTmpTxt[i];
										var pid = 0;
										if (i > 0){
											pid =  splitTmpTxt[i-1];
										}
										// console.log("ADD 004 --- id : " + id + " name : " + name + " pid : " + pid);
										arrayVal.push(jsonDataSet(id, name, pid));
									}
								}
							}
						} else if (prevVal == "" && data.cnt != 0 ) {
							// 첫번째 데이터가 count 가 0일때
							var tmpTxtX = data.campaign_folder_txt;
							var splitTmpTxtX = tmpTxtX.split("\\");
						
							//console.log("00001 ==== " + tmpTxtX);
							//console.log("splitTmpTxtX.length ==== " + splitTmpTxtX.length);
							var tmpPreDataString = "";
							for (var io = 0; io < splitTmpTxtX.length; io++) {
								//console.log("splitTmpTxtX ==== " + splitTmpTxtX[io] + " === " + io);
								var tmpPidStr = "";
								if (io == 0) {
									tmpPidStr = 0;
									tmpPreDataString = splitTmpTxtX[io];
									arrayVal.push(jsonDataSet(splitTmpTxtX[io], splitTmpTxtX[io], io));
								} else {
									tmpPidStr = splitTmpTxtX[io];
									arrayVal.push(jsonDataSet(splitTmpTxtX[io], splitTmpTxtX[io], tmpPreDataString));
									tmpPreDataString = splitTmpTxtX[io];
								}
								//console.log("JSON.stringify ========== : " + JSON.stringify(arrayVal));
							}
						}
						
						//console.log("002 : " + tmpTxt + " ::: " + splitTmpTxt[data.cnt] + " ::: " + splitTmpTxt[data.cnt-1]);
						
						if (splitTmpTxt.length == 1) {  // 첫번째 항목이면
							//console.log("ADD 005 --- id : " + tmpTxt + " name : " + tmpTxt + " pid : 0");
							jsonData.id = tmpTxt;
							jsonData.name = tmpTxt;
							jsonData.pid = "0";
						
							arrayVal.push(jsonData);
						}
						//console.log("==================================");
						//console.log(jsonData);
						//console.log(arrayVal);
						//console.log("-------------------------------------------------------------------");
						prevVal = data.campaign_folder_txt;
					});
					$.fn.zTree.init($("#tree"), setting, arrayVal);
					//console.log(arrayVal);
				}
			}
		});
		fn_search();
		
		$("#expandAllBtn").bind("click", {type:"expandAll"}, expandNode);
		$("#collapseAllBtn").bind("click", {type:"collapseAll"}, expandNode);
		
		if ("${cal }" != "" && "${cal }" != null && "${cal }" != "null"){
			fn_getCampaignDtl('${cal }');
		}
	});
	
	function expandNode(e) {
		var zTree = $.fn.zTree.getZTreeObj("tree"),
		type = e.data.type,
		nodes = zTree.getSelectedNodes();
		if (type.indexOf("All")<0 && nodes.length == 0) {
			alert("Please select one parent node at first...");
		}
		if (type == "expandAll") {
			zTree.expandAll(true);
		} else if (type == "collapseAll") {
			zTree.expandAll(false);
		}
	}
	
	// Jsondata 세팅후 리턴
	function jsonDataSet(id, name, pid){
		var jsonData = new Object();
		jsonData.id = id;
		jsonData.name = name;
		jsonData.pid = pid;
		return jsonData;
	}
	
	// 폴더 Depth 가 같을때 최종 폴더명만 다르면 true 아니면 해당 폴더 배열 위치 리턴
	function fnChkFolderPath(splitTmpTxt, splitPrevTxt){
		for(var i = 0 ; i < splitTmpTxt.length ; i++){
			//console.log("splitTmpTxt : " + splitTmpTxt[i] + " ::::: splitPrevTxt : " + splitPrevTxt[i]);
			if (splitTmpTxt[i] != splitPrevTxt[i]) {
				//console.log("################################## return : " + i);
				return i;
			}
		}
	}
	
	/* 조회 */
	function fn_search() {
		//${staticServerType }
		jQuery.ajax({
			url           : '${staticPATH }/campaignList.do?serverType=${staticServerType }',
			dataType      : "JSON",
			scriptCharset : "UTF-8",
			async         : true,
			type          : "POST",
			data          : {treeValue : $("#TREE_VALUE").val()},
			success: function(result, option) {
				if (option=="success"){
					var list = result.CampaignList;
					$("#campaignList > tbody tr").remove();
					var txt ="";
					if (list.length>0){
						$.each(list, function(key){
							var data = list[key];
							txt = "<tr>";
							txt += "<td align=\"center\" class=\"listtd\">"+data.campaigncd+"</td>";
							txt += "<td align=\"left\"   class=\"listtd\"><a href=\"javascript:fn_getCampaignDtl('"+data.campaignid+"');\" class='link'>"+data.campaignnm+"</td>";
							//txt += "<td align=\"left\"   class=\"listtd\">"+nvl(data.campaign_desc,'')+"</td>";
							txt += "<td align=\"center\" class=\"listtd\">"+data.campaign_owner_nm+"</td>";
							txt += "<td align=\"center\" class=\"listtd\">"+nvl(data.run_dttm,'')+"</td>";
							txt += "</tr>";
							$("#campaignList > tbody:last").append(txt);
						});
					} else {
						txt += "<tr><td align=\"center\" class=\"listtd\" colspn=\"\9\">데이터가 없습니다.</td></tr>";
						$("#campaignList > tbody:last").append(txt);
					}
					//빈 row 채우기
					if (list.length > 0 && list.length < result.rowRange ){
						for(var i=list.length; i<result.rowRange; i++){
							txt +="<tr>";
							txt +="<td align=\"center\" class=\"listtd\">&nbsp;</td>";
							txt +="<td align=\"center\" class=\"listtd\">&nbsp;</td>";
							txt +="<td align=\"center\" class=\"listtd\">&nbsp;</td>";
							txt +="<td align=\"center\" class=\"listtd\">&nbsp;</td>";
							txt +="<td align=\"center\" class=\"listtd\">&nbsp;</td>";
							txt +="</tr>";
						}
					}
				} else {
					alert("에러가 발생하였습니다.");
				}
			},
			error: function(result, option) {
				alert("에러가 발생하였습니다.");
			}
		});
	};
	
	function zTreeOnClick(event, treeId, treeNode) {
		var treeValue = treeNode.name;
		$("#TREE_VALUE").val(treeValue);
		// console.log("event : " + event);
		// console.log("treeId : " + treeId);
		// console.log("treeNode.name : " + treeNode.name);
		// console.log("treeNode.id : " + treeNode.id);
		// console.log("treeNode.pid : " + treeNode.pid);
		// console.log("treeValue : " + treeValue);
		fn_search();
	};
	
	$(function(){
		$('#myTab a').click(function (e) {
		});
		$("#propertyEdit").click(function() {
			var campaign_id = $("#CAMPAIGNID").val();
			window.open("${staticPATH }/campaign/property.do?CampaignId="+campaign_id, "propertyPop", "width=1100, height=450, status=1");
		});
		$("#offerEdit").click(function() {
			$("#modal-testNew").modal({
				remote: "${staticPATH }/offer/offer.do"
			});
		});
		$("#scheduleEdit").click(function() {
			var campaign_id = $("#CAMPAIGNID").val();
			window.open("${staticPATH }/schedule/schedule.do?CampaignId="+campaign_id, "schedulePop", "width=1100, height=600, status=1");
		});
	});
	
	//채널 추가
	function fn_addChannel(cellid,campaignid) {
		var frmChannel = document.frmChannel;
		$("#ChannelCELLID").val(cellid);
		$("#ChannelCampaignId").val(campaignid);
		window.open("about:blank", "POP_CHANNEL", "top=50,left=80, location=no,status=no,toolbar=no,scrollbars=yes,width=1070,height=500");
		frmChannel.action = "${staticPATH }/channel/channelInfo.do";
		frmChannel.target = "POP_CHANNEL";
		frmChannel.method = "POST";
		frmChannel.submit();
	}
	
	// 채널 정보 삭제 
	function fn_delChannel(cellid, channel_cd){
		if (!confirm("삭제 하시겠습니까?")){
			return;
		}
		$("#ChannelCELLID").val(cellid);
		$("#CHANNEL_CD").val(channel_cd);
		var campaign_id = $("#CAMPAIGNID").val();
		jQuery.ajax({
			url           : '${staticPATH }/delChannelInfo.do',
			dataType      : "JSON",
			scriptCharset : "UTF-8",
			async         : true,
			type          : "POST",
			data          : $("#frmChannel").serialize(),
			success: function(result, option) {
				if (option=="success"){
					alert("삭제되었습니다");
					fn_getCampaignDtl(campaignid);
				} else {
					alert("에러가 발생하였습니다.");
				}
			},
			error: function(result, option) {
				alert("에러가 발생하였습니다.");
			}
		});
	}
	
	function fn_getCampaignDtl(campaignid) {
		$("#optionDiv").hide();
		var reTurnDivView = fn_campaignInfoAll(campaignid);
		if (reTurnDivView == "ERROR"){
		} else {
			$("#optionDiv").show();
		}
		/*
		  wrapWindowByMask();
		  $("#optionDiv").hide();
		  chkTime(campaignid);
		  $("#optionDiv").show();
		  closeWindowByMask();
		*/
	}
	
	function chkTime(campaignid){
		// 캠페인 속성 조회
		fn_property(campaignid);
		// 캠페인 오퍼 조회
		fn_offer(campaignid);
		// 캠페인 채널 조회
		fn_channel(campaignid);
		// 일정 조회
		fn_searchScheduleList(campaignid);
	}
	
	function fn_campaignInfoAll(campaignid){
		jQuery.ajax({
			url           : '${staticPATH }/getCampaignInfoAll.do',
			dataType      : "JSON",
			scriptCharset : "UTF-8",
			async         : true,
			type          : "POST",
			data          : {campaignid   : campaignid},
			beforeSend:function(){
					wrapWindowByMask();
			},
			success: function(result, option) {
				if (option=="success"){
					if (result.batchDtCheck == "ERROR"){
						alert("데이터 전송 방식이 Batch일 경우 \n\n캠페인 시작일을 내일부터 지정 할 수 있습니다.")
						return "ERROR";
					} else {
						/* 캠페인 요약/속성 정보 ##################################### */
						$('#summary').css('display', '');
						$('#CAMPAIGNNAME').html(result.bo.campaignname);
						$('#CAMPAIGNCODE').html(result.bo.campaigncode);
						$('#CAMP_BGN_DT1').html(result.bo.camp_bgn_dt1);
						$('#CAMP_BGN_DT2').html(result.bo.camp_bgn_dt2);
						$('#CAMP_BGN_DT3').html(result.bo.camp_bgn_dt3);
						$('#CAMP_END_DT1').html(result.bo.camp_end_dt1);
						$('#CAMP_END_DT2').html(result.bo.camp_end_dt2);
						$('#CAMP_END_DT3').html(result.bo.camp_end_dt3);
						$('#CAMP_TERM_DAY').html(result.bo.camp_term_day);
						if (result.bo.camp_term_day == null){
							$("#cmpgnDtType1").show();
							$("#cmpgnDtType2").hide();
						} else if (result.bo.camp_term_day != null){
							$("#cmpgnDtType1").hide();
							$("#cmpgnDtType2").show();
						}
						console.log("result.bo.camp_status_cd : " + result.bo.camp_status_cd);
						console.log("result.runScheduleCnt : " + result.runScheduleCnt);
						if (result.bo.camp_status_cd == "START" && parseInt(result.runScheduleCnt) > 0){
							$("#campaignStopDiv").show();
						} else {
							$("#campaignStopDiv").hide();
						}
						$('#AUDIENCE_NM').html(result.bo.audience_nm);
						$('#MANUAL_TRANS_NM').html(result.bo.manual_trans_nm);
						$('#OFFER_DIRECT_YN').html(result.bo.offer_direct_yn);
						$('#CHANNEL_PRIORITY_YN').html(result.bo.channel_priority_yn);
						$('#CREATE_NM').html(result.bo.create_nm);
						$('#CREATE_DT').html(result.bo.create_dt);
						$('#UPDATE_NM').html(result.bo.update_nm);
						$('#UPDATE_DT').html(result.bo.update_dt);
						$('#CAMPAIGNID').val(result.bo.campaignid);
						$('#CAMPAIGNNAME_SUMMARY').text(result.boSummary.campaignname);
						$('#CAMPAIGNCODE_SUMMARY').text(result.boSummary.campaigncode);
						var tmpCampaignDetail = "";
						if (result.boSummary.campaign_detail == "11"){
							tmpCampaignDetail = "전사";
						} else if (result.boSummary.campaign_detail == "12"){
							tmpCampaignDetail = "카테고리";
						} else if (result.boSummary.campaign_detail == "13"){
							tmpCampaignDetail = "쇼킹딜";
						} else if (result.boSummary.campaign_detail == "14"){
							tmpCampaignDetail = "개인화";
						} else if (result.boSummary.campaign_detail == "15"){
							tmpCampaignDetail = "실시간";
						} else if (result.boSummary.campaign_detail == "16"){
							tmpCampaignDetail = "내부기타";
						} else if (result.boSummary.campaign_detail == "121"){
							tmpCampaignDetail = "카드사";
						} else if (result.boSummary.campaign_detail == "122"){
							tmpCampaignDetail = "제휴사";
						} else if (result.boSummary.campaign_detail == "123"){
							tmpCampaignDetail = "외부기타";
						}
						$('#CAMPAIGN_DETAIL').text(tmpCampaignDetail);
						var tmpCampaignOfferCostGubun = "";
						if (result.boSummary.campaign_offer_cost_gubun == "1"){
							tmpCampaignOfferCostGubun = "활성";
						} else if (result.boSummary.campaign_offer_cost_gubun == "2"){
							tmpCampaignOfferCostGubun = "홍보";
						} else if (result.boSummary.campaign_offer_cost_gubun == "3"){
							tmpCampaignOfferCostGubun = "휴면";
						} else if (result.boSummary.campaign_offer_cost_gubun == "4"){
							tmpCampaignOfferCostGubun = "신규";
						}
						$('#CAMPAIGN_OFFER_COST_GUBUN').text(tmpCampaignOfferCostGubun);
						// Schedule 값세팅
						$('#scheduleCampaignCode').text("[" + result.boSummary.campaigncode+"] " + result.boSummary.campaignname);
						$('#scheduleCAMPAIGNCODE').val(result.boSummary.campaigncode);
						$('#scheduleCampaignId').val(result.bo.campaignid);
						var tmpGubun = "";
						if (result.boSummary.campaigngubun == "1"){
							tmpGubun = "내부";
						} else if (result.boSummary.campaigngubun == "2"){
							tmpGubun = "외부";
						}
						$("#scheduleDel").show();
						$("#scheduleEdit").show();
						$("#scheduleAdd").show();
						$("#viewMultiDiv").hide();
						$("#scheduleAddTr").show();
						var tmpType = "";
						if (result.boSummary.campaigntype == "1"){
							tmpType = "일반캠페인";
						} else if (result.boSummary.campaigntype == "2"){
							tmpType = "A|B캠페인";
						} else if (result.boSummary.campaigntype == "3"){
							tmpType = "멀티캠페인";
							$("#scheduleDel").hide();
							$("#scheduleEdit").hide();
							$("#scheduleAdd").hide();
							$("#viewMultiDiv").show();
							$("#scheduleAddTr").hide();
						}
						result.boSummary.campaigntype
						$('#CAMPAIGNGUBUN').text(tmpGubun);
						$('#CAMPAIGNTYPE').text(tmpType);
						$('#SENDDATETYPE').text(result.boSummary.senddatetype);
						/* 캠페인 요약/속성 정보 ##################################### /// */
						/* 캠페인 오퍼 정보 ##################################### */
						var list = result.offer_list;
						//console.log("offer_list : " + result.offer_list);
						//console.log("offerUseChk : " + result.offerUseChk);
						//console.log("dummyOfferChk : " + result.dummyOfferChk);
						//console.log("dummyOfferChk : " + result.dummyOfferChk);
						var txt = '<table class="table table-striped table-hover table-condensed table-bordered" >';
						txt += '<colgroup>';
						txt += '<col width="30%"/>';
						txt += '<col width="25%"/>';
						txt += '<col width="45%"/>';
						txt += '</colgroup>     ';
						txt += '<tr class="info">';
						txt += '<th align="center">고객 세그먼트</th>';
						txt += '<th align="center">오퍼종류</th>';
						txt += '<th align="center">노출명</th>';
						txt += '</tr>';
						$.each(list, function(key){
							var data = list[key];
							//console.log(data.campaignid + " / " + data.campaignname);
							txt += "<tr>";
							txt += "<td>"+data.cellname+"</td>";
							if (data.offer_sys_cd == 'ZZ'){
								txt += "<td>"+data.offername+"</td>";
							} else {
								txt += "<td>";
								txt += "<a href=\"javascript:fn_clickOffer('"+data.offer_type_cd+"', '"+data.offer_sys_cd+"' , '"+data.cellid+"' , '"+data.offerid+"', '"+data.campaignid+"')\" class=\"link\">"+data.offername +"&nbsp; </a>";
								txt += "</td>";
							}
							txt += "<td>"+nvl(data.disp_name, '')+"</td>";
							txt += "</tr>";
						});
						txt += "</table>";
						$("#offerList").html(txt);
						/* 캠페인 오퍼 정보 ##################################### /// */
						/* 캠페인 채널 정보 ##################################### */
						var list = result.channel_list;
						var txt ="";
						txt += "<table class='table table-striped table-hover table-condensed table-bordered' width='100%' border='0' cellpadding='0' cellspacing='0'>";
						if (list.length>0) {
							if (result.channelValiChk =="N"){
								alert("대상수준이 PCID일경우에는 토스트배너만 사용이 가능합니다");
								return;
							} else if (result.channelValChkforMobile != "Y"){
								alert("대상수준이 DEVICEID일 경우에는 모바일 알리미 채널만 사용이 가능합니다.");
								return;
							} else {
								var old_celid2 = "";
								var old_cellname2 = "";
								txt += "<colgroup>";
								txt += "<col width='15%'/>";
								txt += "<col width='15%'/>";
								txt += "<col width=''/>";
								txt += "<col width='10%'/>";
								txt += "<col width='10%'/>";
								txt += "</colgroup>";
								$.each(list, function(key){
									var data = list[key];
									txt += "<tr>";
									if (data.cellname != old_cellname2){
										txt += "<td align=\"left\" class=\"listtd\"rowspan="+data.cellrow+">"+data.cellname+"</td>";
									}
									if (data.channel_nm != null){
										txt += "<td align=\"left\" class=\"listtd\"><a href=\"javascript:fn_clickChannel('"+data.cellid+"','"+data.channel_cd+"');\" class='link'>"+data.channel_nm+"</a></td>";
									} else {
										txt += "<td align=\"left\" class=\"listtd\"></td>";
									}
									txt += "<td align=\"left\" class=\"listtd\"";
									if (data.channel_cd =='TOAST'){
										txt += "title ='"+data.toast_title+"'";
									}
									if (data.channel_cd =='SMS'){
										txt += "title ='"+data.sms_msg+"'";
									}
									if (data.channel_cd =='EMAIL'){
										txt += "title ='"+ data.email_name+"'";
									}
									if (data.channel_cd =='MOBILE'){
										txt += "title ='"+  data.mobile_disp_title+"'";
									}
									if (data.channel_cd =='LMS'){
										txt += "title ='"+  data.lms_title+"'";
									}
									txt +=">";
									if (data.channel_cd =='TOAST'){
										txt +=(data.toast_title).substring(0,45);
										if ((data.toast_title).substring(0,45).length>=18){
											txt +='...';
										}
									}
									if (data.channel_cd =='SMS'){
										txt +=(data.sms_msg).substring(0,45);
										if ((data.sms_msg).substring(0,45).length>=18){
											txt +='...';
										}
									}
									if (data.channel_cd =='EMAIL'){
										txt +=(data.email_name).substring(0,45);
										if ((data.email_name).substring(0,45).length>=18){
											txt +='...';
										}
									}
									if (data.channel_cd =='MOBILE'){
										txt +=(data.mobile_disp_title).substring(0,45);
										if ((data.mobile_disp_title).substring(0,45).length>=18){
											txt +='...';
										}
									}
									if (data.channel_cd =='LMS'){
										txt +=(data.lms_title).substring(0,45);
										if ((data.lms_title).substring(0,45).length>=18){
											txt +='...';
										}
									}
									txt +="</td>";
									if (data.channel_cd != null && data.camp_status_cd =='EDIT'){
										txt += "<td align=\"center\" class=\"listtd\"><a href=\"javascript:fn_delChannel('"+data.cellid+"','"+data.channel_cd+"');\" class='link'>"+'삭제'+"</a></td>";
									} else {
										txt += '<td></td>';
									}
									if (data.cellid !=old_celid2){
										if (data.camp_status_cd =='EDIT'){
											txt += "<td align=\"center\" class=\"listtd\"><a href=\"javascript:fn_addChannel('"+data.cellid+"','"+data.campaignid+"');\" class='link' rowspan="+data.cellrow+">"+'추가'+"</a></td>";
											//txt += '<td></td>';
										} else {
											txt += '<td></td>';
										}
									} else {
										txt += '<td></td>';
									}
									old_celid2 = data.cellid;
									old_cellname2 =  data.cellname;
									txt += "</tr>";
								});
							}
						} else {
							txt += "<td align=\"center\" class=\"listtd\" colspn=\"5\">데이터가 없습니다.</td>";
						}
						txt += "</table>";
						$("#search_channel").html(txt);
						/* 캠페인 채널 정보 ##################################### /// */
						/* 캠페인 일정 정보 ##################################### */
						if (result.scheduleBo.rsrv_gubun_code_name == null || result.scheduleBo.rsrv_gubun_code_name == "null"){
							$("#scheduleTable").hide();
							$("#scheduleListDiv").hide();
						} else {
							$("#scheduleTable").show();
							$("#scheduleListDiv").show();
							fn_searchSchedule();
							if (option=="success"){
								var scheduleScheduler = "";
								var scheduleRsrvDate = "";
								// 일정
								scheduleScheduler += result.scheduleBo.rsrv_gubun_code_name;
								if (result.scheduleBo.rsrv_gubun_code == '03'){
									scheduleScheduler += result.scheduleBo.rsrv_day + "일";
								}
								if (result.scheduleBo.rsrv_gubun_code == '02' && result.scheduleBo.rsrv_week_day.indexOf('2') != '-1'){
									scheduleScheduler += "월";
								}
								if (result.scheduleBo.rsrv_gubun_code == '02' && result.scheduleBo.rsrv_week_day.indexOf('3') != '-1'){
									scheduleScheduler += "화";
								}
								if (result.scheduleBo.rsrv_gubun_code == '02' && result.scheduleBo.rsrv_week_day.indexOf('4') != '-1'){
									scheduleScheduler += "수";
								}
								if (result.scheduleBo.rsrv_gubun_code == '02' && result.scheduleBo.rsrv_week_day.indexOf('5') != '-1'){
									scheduleScheduler += "목";
								}
								if (result.scheduleBo.rsrv_gubun_code == '02' && result.scheduleBo.rsrv_week_day.indexOf('6') != '-1'){
									scheduleScheduler += "금";
								}
								if (result.scheduleBo.rsrv_gubun_code == '02' && result.scheduleBo.rsrv_week_day.indexOf('7') != '-1'){
									scheduleScheduler += "토";
								}
								if (result.scheduleBo.rsrv_gubun_code == '02' && result.scheduleBo.rsrv_week_day.indexOf('1') != '-1'){
									scheduleScheduler += "일";
								}
								if (result.scheduleBo.rsrv_gubun_code == '01'
										|| result.scheduleBo.rsrv_gubun_code == '02'
										|| result.scheduleBo.rsrv_gubun_code == '03'
										|| result.scheduleBo.rsrv_gubun_code == '04'){
									scheduleScheduler += result.scheduleBo.rsrv_hour + "시 " + result.scheduleBo.rsrv_minute + "분";
								}
								if (result.scheduleBo.rsrv_gubun_code == '06'){
									if (result.scheduleBo.rsrv_everytime == 'Y'){
										scheduleScheduler += "매시간 " + result.scheduleBo.rsrv_timehourfrom + "시 ~";
									}
									scheduleScheduler += result.scheduleBo.rsrv_timehourto + "시 " + result.scheduleBo.rsrv_timemin + "분";
								}
								// 추출기간
								scheduleRsrvDate += "";
								if (result.scheduleBo.rsrv_gubun_code != '05'){
									scheduleRsrvDate += result.scheduleBo.rsrv_start_dt + " ~ " + result.scheduleBo.rsrv_end_dt;
								}
								//console.log(scheduleScheduler);
								//console.log(scheduleScheduler.length);
								$("#scheduleScheduler").text((scheduleScheduler == "" || scheduleScheduler == null || scheduleScheduler == "null")?"":scheduleScheduler);
								$("#scheduleRsrvDate").text((scheduleRsrvDate == "null ~ null" || scheduleRsrvDate == " ~ ")?"":scheduleRsrvDate);
								$("#camp_term_cd").val(result.scheduleBo.camp_term_cd);
								$("#camp_end_dt").val(result.scheduleBo.camp_end_dt);
								$("#channel_priority_yn").val(result.scheduleBo.channel_priority_yn);
								$("#minDispDt").val(result.scheduleBo.minDispDt);
							} else {
								alert("에러가 발생하였습니다.");
							}
						}
						//console.log("result.scheduleBo.camp_status_cd : " + result.scheduleBo.camp_status_cd);
						if (result.scheduleBo.camp_status_cd != 'START'){
							$("#multiSaveBtn").show();
						} else {
							$("#multiSaveBtn").hide();
						}
						/* 캠페인 일정 정보 ##################################### /// */
						return "SUCC";
					}
				} else {
					alert("에러가 발생하였습니다.");
				}
			},
			complete:function(){
				closeWindowByMask();
			},
			error: function(result, option) {
				alert("에러가 발생하였습니다.");
			}
		});
	}
	
	function fn_property(campaignid){
		//켐패인 속성 조회
		jQuery.ajax({
			url           : '${staticPATH }/getCampaignInfo.do',
			dataType      : "JSON",
			scriptCharset : "UTF-8",
			async         : true,
			type          : "POST",
			data          : {campaignid   : campaignid},
			success: function(result, option) {
				if (option=="success"){
					$('#summary').css('display', '');
					$('#CAMPAIGNNAME').html(result.bo.campaignname);
					$('#CAMPAIGNCODE').html(result.bo.campaigncode);
					$('#CAMP_BGN_DT1').html(result.bo.camp_bgn_dt1);
					$('#CAMP_BGN_DT2').html(result.bo.camp_bgn_dt2);
					$('#CAMP_BGN_DT3').html(result.bo.camp_bgn_dt3);
					$('#CAMP_END_DT1').html(result.bo.camp_end_dt1);
					$('#CAMP_END_DT2').html(result.bo.camp_end_dt2);
					$('#CAMP_END_DT3').html(result.bo.camp_end_dt3);
					$('#CAMP_TERM_DAY').html(result.bo.camp_term_day);
					if (result.bo.camp_term_day == null){
						$("#cmpgnDtType1").show();
						$("#cmpgnDtType2").hide();
					} else if (result.bo.camp_term_day != null){
						$("#cmpgnDtType1").hide();
						$("#cmpgnDtType2").show();
					}
					$('#AUDIENCE_NM').html(result.bo.audience_nm);
					$('#MANUAL_TRANS_NM').html(result.bo.manual_trans_nm);
					$('#OFFER_DIRECT_YN').html(result.bo.offer_direct_yn);
					$('#CHANNEL_PRIORITY_YN').html(result.bo.channel_priority_yn);
					$('#CREATE_NM').html(result.bo.create_nm);
					$('#CREATE_DT').html(result.bo.create_dt);
					$('#UPDATE_NM').html(result.bo.update_nm);
					$('#UPDATE_DT').html(result.bo.update_dt);
					$('#CAMPAIGNID').val(result.bo.campaignid);
					$('#CAMPAIGNNAME_SUMMARY').text(result.boSummary.campaignname);
					$('#CAMPAIGNCODE_SUMMARY').text(result.boSummary.campaigncode);
					// Schedule 값세팅
					$('#scheduleCampaignCode').text("[" + result.boSummary.campaigncode+"] " + result.boSummary.campaignname);
					$('#scheduleCAMPAIGNCODE').val(result.boSummary.campaigncode);
					$('#scheduleCampaignId').val(result.bo.campaignid);
					var tmpGubun = "";
					if (result.boSummary.campaigngubun == "1"){
						tmpGubun = "내부";
					} else if (result.boSummary.campaigngubun == "2"){
						tmpGubun = "외부";
					}
					$("#scheduleDel").show();
					$("#scheduleEdit").show();
					var tmpType = "";
					if (result.boSummary.campaigntype == "1"){
						tmpType = "일반캠페인";
					} else if (result.boSummary.campaigntype == "2"){
						tmpType = "A|B캠페인";
					} else if (result.boSummary.campaigntype == "3"){
						tmpType = "멀티캠페인";
						$("#scheduleDel").hide();
						$("#scheduleEdit").hide();
					}
					result.boSummary.campaigntype
					$('#CAMPAIGNGUBUN').text(tmpGubun);
					$('#CAMPAIGNTYPE').text(tmpType);
					$('#SENDDATETYPE').text(result.boSummary.senddatetype);
				} else {
					alert("에러가 발생하였습니다.");
				}
			},
			beforeSend:function(){
			},
			complete:function(){
			},
			error: function(result, option) {
				alert("에러가 발생하였습니다.");
			}
		});
	}
	
	function fn_offer(campaignid){
	//켐패인 오퍼 리스트  조회
		jQuery.ajax({
			url           : '${staticPATH }/getOfferInfoList.do',
			dataType      : "JSON",
			scriptCharset : "UTF-8",
			async         : true,
			type          : "POST",
			data          : {campaignid   : campaignid},
			success: function(result, option) {
				if (option=="success"){
					var list = result.offer_list;
					//console.log("offer_list : " + result.offer_list);
					//console.log("offerUseChk : " + result.offerUseChk);
					//console.log("dummyOfferChk : " + result.dummyOfferChk);
					//console.log("dummyOfferChk : " + result.dummyOfferChk);
					var txt = '<table class="table table-striped table-hover table-condensed table-bordered" >';
						txt += '<colgroup>';
						txt += '<col width="30%"/>';
						txt += '<col width="25%"/>';
						txt += '<col width="45%"/>';
						txt += '</colgroup>     ';
						txt += '<tr class="info">';
						txt += '<th align="center">고객 세그먼트</th>';
						txt += '<th align="center">오퍼종류</th>';
						txt += '<th align="center">노출명</th>';
						txt += '</tr>';
					$.each(list, function(key){
						var data = list[key];
						//console.log(data.campaignid + " / " + data.campaignname);
						txt += "<tr>";
						txt += "<td>"+data.cellname+"</td>";
						if (data.offer_sys_cd == 'ZZ'){
							txt += "<td>"+data.offername+"</td>";
						} else {
							txt += "<td>";
							txt += "<a href=\"javascript:fn_clickOffer('"+data.offer_type_cd+"', '"+data.offer_sys_cd+"' , '"+data.cellid+"' , '"+data.offerid+"', '"+data.campaignid+"')\" class=\"link\">"+data.offername +"&nbsp; </a>";
							txt += "</td>";
						}
						txt += "<td>"+nvl(data.disp_name, '')+"</td>";
						txt += "</tr>";
					});
					txt += "</table>";
					$("#offerList").html(txt);
				} else {
					alert("에러가 발생하였습니다.");
				}
			},
			beforeSend:function(){
			},
			complete:function(){
			},
			error: function(result, option) {
				alert("에러가 발생하였습니다.");
			}
		});
	}
	
	//켐패인 채널 리스트  조회
	function fn_channel(campaignid){
		jQuery.ajax({
			url           : '${staticPATH }/getChannelInfoList.do',
			dataType      : "JSON",
			scriptCharset : "UTF-8",
			async         : true,
			type          : "POST",
			data          : {campaignid   : campaignid},
			success: function(result, option) {
				if (option=="success"){
					//$('#channel').css('display', '');
					var list = result.channel_list;
					var txt ="";
					txt += "<table class='table table-striped table-hover table-condensed table-bordered' width='100%' border='0' cellpadding='0' cellspacing='0'>";
					if (list.length>0) {
						if (result.channelValiChk =="N"){
							alert("대상수준이 PCID일경우에는 토스트배너만 사용이 가능합니다");
							return;
						} else if (result.channelValChkforMobile != "Y"){
							alert("대상수준이 DEVICEID일 경우에는 모바일 알리미 채널만 사용이 가능합니다.");
							return;
						} else {
							var old_celid2 = "";
							var old_cellname2 = "";
							txt += "<colgroup>";
							txt += "<col width='15%'/>";
							txt += "<col width='15%'/>";
							txt += "<col width=''/>";
							txt += "<col width='10%'/>";
							txt += "<col width='10%'/>";
							txt += "</colgroup>";
							$.each(list, function(key){
								var data = list[key];
								txt += "<tr>";
								if (data.cellname != old_cellname2){
									txt += "<td align=\"left\" class=\"listtd\"rowspan="+data.cellrow+">"+data.cellname+"</td>";
								}
								if (data.channel_nm != null){
									txt += "<td align=\"left\" class=\"listtd\"><a href=\"javascript:fn_clickChannel('"+data.cellid+"','"+data.channel_cd+"');\" class='link'>"+data.channel_nm+"</a></td>";
								} else {
									txt += "<td align=\"left\" class=\"listtd\"></td>";
								}
								txt += "<td align=\"left\" class=\"listtd\"";
								if (data.channel_cd =='TOAST'){
									txt += "title ='"+data.toast_title+"'";
								}
								if (data.channel_cd =='SMS'){
									txt += "title ='"+data.sms_msg+"'";
								}
								if (data.channel_cd =='EMAIL'){
									txt += "title ='"+ data.email_name+"'";
								}
								if (data.channel_cd =='MOBILE'){
									txt += "title ='"+  data.mobile_disp_title+"'";
								}
								if (data.channel_cd =='LMS'){
									txt += "title ='"+  data.lms_title+"'";
								}
								txt +=">";
								if (data.channel_cd =='TOAST'){
									txt +=(data.toast_title).substring(0,45);
									if ((data.toast_title).substring(0,45).length>=18){
										txt +='...';
									}
								}
								if (data.channel_cd =='SMS'){
									txt +=(data.sms_msg).substring(0,45);
									if ((data.sms_msg).substring(0,45).length>=18){
										txt +='...';
									}
								}
								if (data.channel_cd =='EMAIL'){
									txt +=(data.email_name).substring(0,45);
									if ((data.email_name).substring(0,45).length>=18){
										txt +='...';
									}
								}
								if (data.channel_cd =='MOBILE'){
									txt +=(data.mobile_disp_title).substring(0,45);
									if ((data.mobile_disp_title).substring(0,45).length>=18){
										txt +='...';
									}
								}
								if (data.channel_cd =='LMS'){
									txt +=(data.lms_title).substring(0,45);
									if ((data.lms_title).substring(0,45).length>=18){
										txt +='...';
									}
								}
								txt +="</td>";
								if (data.channel_cd != null && data.camp_status_cd =='EDIT'){
									txt += "<td align=\"center\" class=\"listtd\"><a href=\"javascript:fn_delChannel('"+data.cellid+"','"+data.channel_cd+"');\" class='link'>"+'삭제'+"</a></td>";
								} else {
									txt += '<td></td>';
								}
								if (data.cellid !=old_celid2){
									if (data.camp_status_cd =='EDIT'){
										txt += "<td align=\"center\" class=\"listtd\"><a href=\"javascript:fn_addChannel('"+data.cellid+"','"+data.campaignid+"');\" class='link' rowspan="+data.cellrow+">"+'추가'+"</a></td>";
									} else {
										txt += '<td></td>';
									}
								} else {
									txt += '<td></td>';
								}
								old_celid2 = data.cellid;
								old_cellname2 =  data.cellname;
								txt += "</tr>";
							});
						}
					} else {
						txt += "<td align=\"center\" class=\"listtd\" colspn=\"5\">데이터가 없습니다.</td>";
					}
					txt += "</table>";
					$("#search_channel").html(txt);
				} else {
					alert("에러가 발생하였습니다.");
					closeWindowByMask();
				}
			},
			beforeSend:function(){
			},
			complete:function(){
			},
			error: function(result, option) {
				alert("에러가 발생하였습니다.");
			}
		});
	}
	
	/* 채널정보 상세보기(수정화면)*/
	function fn_clickChannel(cellid, channel_cd){
		if (!true) {
			var txt = "fn_clickChannel(cellid, channel_cd)\n"
				+ "cellid: " + cellid + "\n"
				+ "channel_cd: " + channel_cd + "\n"
				;
			alert(txt);
		}
		
		var frmChannel = document.frmChannel;
		$("#ChannelCELLID").val(cellid);
		$("#CHANNEL_CD").val(channel_cd);
		pop = window.open('', 'POP_CHANNEL', 'top=50,left=80, location=no,status=no,toolbar=no,scrollbars=yes');
		if (channel_cd == "TOAST"){
			frmChannel.action = "${staticPATH }/channel/channelToast.do";
		}
		if (channel_cd == "SMS"){
			frmChannel.action = "${staticPATH }/channel/channelSms.do";
		}
		if (channel_cd == "EMAIL"){
			frmChannel.action = "${staticPATH }/channel/channelEmail.do";
		}
		if (channel_cd == "MOBILE"){
			frmChannel.action = "${staticPATH }/channel/channelMobile.do";
		}
		if (channel_cd == "LMS"){
			frmChannel.action = "${staticPATH }/channel/channelLms.do";
		}
		frmChannel.target = "POP_CHANNEL";
		frmChannel.method = "POST";
		frmChannel.submit();
		pop.focus();
	}
	
	/* 오퍼 종류 선택시 오퍼정보 입력할수 있는 팝업창 출력 */
	function fn_clickOffer(offer_type_cd, offer_sys_cd, cellid, offerid, campaignid){
		var type = offer_sys_cd + offer_type_cd;
		var frm = document.form;
		$("#CELLID").val(cellid);
		$("#OFFERID").val(offerid);
		$("#CampaignId").val(campaignid);
		if (type == "OMCU" || type == "MMCU" || type == "MMPN" ){ //일반 쿠폰(OMCU), 도서쿠폰(MMCU), 도서포인트(MMPN)
			pop = window.open('', 'POP_OFFER1', 'top=150,left=100, location=no,status=no,toolbar=no,scrollbars=yes');
				frm.action = "${staticPATH }/offer/offerCoupon.do";
				frm.target = "POP_OFFER1";
				frm.method = "POST";
				frm.submit();
				pop.focus();
		} else if (type == "OMPN" || type == "OMMI" || type == "OMOC" || type == "OMDP"){//일반포인트(OMPN), 일반마일리지(OMMI), 일반OKCashBack(OMOC), 즉시할인(OMDP)
			pop = window.open('', 'POP_OFFER1', 'top=150,left=100, location=no,status=no,toolbar=no,scrollbars=yes');
				frm.action = "${staticPATH }/offer/offerPoint.do";
				frm.target = "POP_OFFER1";
				frm.method = "POST";
				frm.submit();
				pop.focus();
		} else {
			alert("오퍼 정보가 유효하지 않습니다.");
		}
	}
	
	/* 유효성 체크 */
	function fn_validation() {
		if ($("#camp_term_cd").val() == "01" && Number($("#LIST_LENGTH").val()) > 0 ){
			//모두 실패건일경우에는 등록 가능
			jQuery.ajax({
				url           : '${staticPATH }/getRunSucessYnChk.do',
				dataType      : "JSON",
				scriptCharset : "UTF-8",
				async         : true,
				type          : "POST",
				data          : $("#formSchedule").serialize(),
				success: function(result, option) {
					if (option=="success"){
						if (result.ALL_FAIL !="Y") {
							alert("캠페인 기간이 From~To일경우에는 일정을 1개만 입력하실수 있습니다");
							return false;
						} else {
							fn_add();
						}
					} else {
						alert("에러가 발생하였습니다.");
					}
				},
				beforeSend:function(){
				},
				complete:function(){
				},
				error: function(result, option) {
					alert("에러가 발생하였습니다.");
				}
			});
		} else {
			fn_add();
		}
	}
	
	/* 일정 추가 */
	function fn_add(){
		if ($("#camp_term_cd").val() == "01"){
			if ( $("#RSRV_DT").val() > $("camp_end_dt").val()){
				alert("추출일자는 캠페인 종료일("+$("camp_end_dt").val()+")보다 보다 작아야합니다");
				$("#RSRV_DT").focus();
				return;
			}
		}
		//캠페인 기간이 from~to일고(camp_term_cd == 01) 채널우선순위적용여부가[Y]일경우 추출일자가 노출일 MIN(SMS노출일, EMAIL노출일, 모바일 노출일) -2일 (minDispDt) 보다 클경우 경고창 출력
		//"채널 노출일 2일전에 대상추출이 되어야 합니다."
		var startDt = $("#RSRV_DT").val();
		if ( $("#camp_term_cd").val() == "01" && $("#channel_priority_yn").val() == "Y" && $("#minDispDt").val() != "" && startDt > $("#minDispDt").val() ){
			alert("캠페인 실행일정은 노출일 -2일 (${bo.minDispDt}) 이전이여야 합니다");
			$("#RSRV_DT").focus();
			return;
		}
		if ($("#RSRV_DT").val() == ""){
			alert("일정을 입력하세요");
			$("#RSRV_DT").focus();
			return;
		}
		if ($("#TO_DATE").val() > $("#RSRV_DT").val()){
			alert("캠페인 실행일은 오늘보다 커야합니다");
			$("#RSRV_DT").focus();
			return;
		}
		if (!confirm("일정을 추가하시겠습니까?")){
			return;
		}
		jQuery.ajax({
			url           : '${staticPATH }/setScheduleList.do',
			dataType      : "JSON",
			scriptCharset : "UTF-8",
			async         : true,
			type          : "POST",
			data          : $("#formSchedule").serialize(),
			success: function(result, option) {
				if (option=="success"){
					alert("일정이 등록 되었습니다");
					fn_searchScheduleList($("#scheduleCampaignId").val());
				} else {
					alert("에러가 발생하였습니다.");
				}
			},
			beforeSend:function(){
			},
			complete:function(){
			},
			error: function(result, option) {
				alert("에러가 발생하였습니다.");
			}
		});
	}
	
	/* 조회 */
	function fn_searchSchedule() {
		jQuery.ajax({
			url           : '${staticPATH }/getScheduleList.do',
			dataType      : "JSON",
			scriptCharset : "UTF-8",
			async         : true,
			type          : "POST",
			data          : { 
				CampaignId      : $("#scheduleCampaignId").val(),
				CAMPAIGNCODE    : $("#scheduleCAMPAIGNCODE").val(),
				selectPageNo    : $("#selectPageNo").val(),
				SEARCH_TYPE     : $("#SEARCH_TYPE").val()
			},
			success: function(result, option) {
				if (option=="success"){
					var list = result.ScheduleList;
					$("#LIST_LENGTH").val(list.length);
					$("#scheduleListTable > tbody tr").remove();
					var txt ="";
					if (list.length>0){
						$.each(list, function(key){
							var data = list[key];
							txt += "<tr>";
							txt += "<td align=\"center\" class=\"listtd\">" + data.num + "</td>";
							if (data.run_start_dt == null){
								txt += "<td align=\"center\" class=\"listtd\"><input type='checkbox' name='CHK_DATE' value='"+ data.rsrv_dt +"' style='margin:-13px 5px -5px 0px;' /></td>";
							} else {
								txt += "<td align=\"center\" class=\"listtd\"><input type='checkbox' disabled='disabled' style='margin:-13px 5px -5px 0px;' /></td>";
							}
							txt += "<td align=\"center\" class=\"listtd\">"+nvl(data.rsrv_dt,'')+"</td>";
							txt += "<td align=\"center\" class=\"listtd\">"+nvl(data.run_start_dt,'')+"</td>";
							txt += "<td align=\"center\" class=\"listtd\">"+nvl(data.run_end_dt,'')+"</td>";
							var tmpStatVal = data.run_status;
							if (tmpStatVal != "")
							var tmpStatArr = tmpStatVal.split("(");
							//console.log(tmpStatArr.length);
							//console.dir(tmpStatArr);
							if (tmpStatArr.length == 2){
								txt += "<td align=\"center\" class=\"listtd\">"+nvl(tmpStatArr[0],'')+"</td>";
								txt += "<td align=\"center\" class=\"listtd\">"+nvl(tmpStatArr[1].replace(')', ''),'')+"</td>";
							} else {
								txt += "<td align=\"center\" class=\"listtd\">"+nvl(tmpStatArr[0],'')+"</td>";
								txt += "<td align=\"center\" class=\"listtd\"></td>";
							}
							txt += "<td align=\"center\" class=\"listtd\">"+nvl(data.create_nm,'')+"</td>";
							txt += "<td align=\"center\" class=\"listtd\">"+nvl(data.create_dt,'')+"</td>";
							txt += "</tr>";
						});
					} else {
						txt += "<tr><td align=\"center\" class=\"listtd\" colspan=\"\9\">데이터가 없습니다.</td></tr>";
						for(var i=1; i<result.rowRange; i++){
							/* 
							txt +="<tr'>";
							txt +="<td align=\"center\" class=\"listtd\" >&nbsp;</td>";
							txt +="<td align=\"center\" class=\"listtd\">&nbsp;</td>";
							txt +="<td align=\"center\" class=\"listtd\">&nbsp;</td>";
							txt +="<td align=\"center\" class=\"listtd\">&nbsp;</td>";
							txt +="<td align=\"center\" class=\"listtd\">&nbsp;</td>";
							txt +="<td align=\"center\" class=\"listtd\">&nbsp;</td>";
							txt +="<td align=\"center\" class=\"listtd\">&nbsp;</td>";
							txt +="<td align=\"center\" class=\"listtd\">&nbsp;</td>";
							txt +="</tr>"; 
							*/
						}
					}
					//빈 row 채우기
					if (list.length > 0 && list.length < result.rowRange ){
						for(var i=list.length; i<result.rowRange; i++){
							/* 
							txt +="<tr'>";
							txt +="<td align=\"center\" class=\"listtd\">&nbsp;</td>";
							txt +="<td align=\"center\" class=\"listtd\">&nbsp;</td>";
							txt +="<td align=\"center\" class=\"listtd\">&nbsp;</td>";
							txt +="<td align=\"center\" class=\"listtd\">&nbsp;</td>";
							txt +="<td align=\"center\" class=\"listtd\">&nbsp;</td>";
							txt +="<td align=\"center\" class=\"listtd\">&nbsp;</td>";
							txt +="<td align=\"center\" class=\"listtd\">&nbsp;</td>";
							txt +="<td align=\"center\" class=\"listtd\">&nbsp;</td>";
							txt +="</tr>"; 
							*/
						}
					}
					txt += "</table>";
					$("#scheduleListTable > tbody:last").append(txt);
					//페이징 처리 시작!!
					var page = "";
					//이전페이지 만들기
					if ( result.selectPage > result.pageRange){
						page +="<a href=\"javascript:fn_pageMove("+ (Number(result.pageStart) - Number(result.pageRange)) +" );\" ><img src=\"<c:url value='/img/btn_left.gif'/>\" width='13px;' height='13px;' /></a>&nbsp;";
					}
					//페이지 숫자
					for(var i=result.pageStart;  i<=result.pageEnd; i++){
						if (result.selectPage == i)  {
							page +="<strong>" + i + "</strong>";
						} else {
							page +="<a href=\"javascript:fn_pageMove("+i+");\">" + i + "</a>";
						};
					};
					//다음페이지 만들기
					if (result.totalPage != result.pageEnd ) {
						page +="&nbsp;<a href=\"javascript:fn_pageMove("+ (Number(result.pageStart) + Number(result.pageRange)) +" );\" ><img src=\"<c:url value='/img/btn_right.gif'/>\" width='13px;' height='13px;' /></a>";
					}
					$("#paging_layer").html(page);
					//페이징 처리 종료
				} else {
					alert("에러가 발생하였습니다.");
				}
			},
			beforeSend:function(){
			},
			complete:function(){
			},
			error: function(result, option) {
			  alert("에러가 발생하였습니다.");
			}
		});
	};
	
	// 일정 조회
	function fn_searchScheduleList(campaignid){
		jQuery.ajax({
			url           : '${staticPATH }/schedule/scheduleList.do',
			dataType      : "JSON",
			scriptCharset : "UTF-8",
			async         : true,
			type          : "POST",
			data          : {CampaignId   : campaignid},
			success: function(result, option) {
				//console.log("result.cnt : " + result.bo.rsrv_gubun_code_name);
				if (result.bo.rsrv_gubun_code_name == null || result.bo.rsrv_gubun_code_name == "null"){
					$("#scheduleTable").hide();
					$("#scheduleListDiv").hide();
				} else {
					$("#scheduleTable").show();
					$("#scheduleListDiv").show();
					fn_searchSchedule();
					if (option=="success"){
						var scheduleScheduler = "";
						var scheduleRsrvDate = "";
						// 일정
						scheduleScheduler += result.bo.rsrv_gubun_code_name;
						if (result.bo.rsrv_gubun_code == '03'){
							scheduleScheduler += result.bo.rsrv_day + "일";
						}
						if (result.bo.rsrv_gubun_code == '02' && result.bo.rsrv_week_day.indexOf('2') != '-1'){
							scheduleScheduler += "월";
						}
						if (result.bo.rsrv_gubun_code == '02' && result.bo.rsrv_week_day.indexOf('3') != '-1'){
							scheduleScheduler += "화";
						}
						if (result.bo.rsrv_gubun_code == '02' && result.bo.rsrv_week_day.indexOf('4') != '-1'){
							scheduleScheduler += "수";
						}
						if (result.bo.rsrv_gubun_code == '02' && result.bo.rsrv_week_day.indexOf('5') != '-1'){
							scheduleScheduler += "목";
						}
						if (result.bo.rsrv_gubun_code == '02' && result.bo.rsrv_week_day.indexOf('6') != '-1'){
							scheduleScheduler += "금";
						}
						if (result.bo.rsrv_gubun_code == '02' && result.bo.rsrv_week_day.indexOf('7') != '-1'){
							scheduleScheduler += "토";
						}
						if (result.bo.rsrv_gubun_code == '02' && result.bo.rsrv_week_day.indexOf('1') != '-1'){
							scheduleScheduler += "일";
						}
						if (result.bo.rsrv_gubun_code == '01'
								|| result.bo.rsrv_gubun_code == '02'
								|| result.bo.rsrv_gubun_code == '03'
								|| result.bo.rsrv_gubun_code == '04'){
							scheduleScheduler += result.bo.rsrv_hour + "시 " + result.bo.rsrv_minute + "분";
						}
						if (result.bo.rsrv_gubun_code == '06'){
							if (result.bo.rsrv_everytime == 'Y'){
								scheduleScheduler += "매시간&nbsp;" + result.bo.rsrv_timehourfrom + "시 ~";
							}
							scheduleScheduler += result.bo.rsrv_timehourto + "시 " + result.bo.rsrv_timemin + "분";
						}
						// 추출기간
						scheduleRsrvDate += "";
						if (result.bo.rsrv_gubun_code != '05'){
							scheduleRsrvDate += result.bo.rsrv_start_dt + " ~ " + result.bo.rsrv_end_dt;
						}
						//console.log(scheduleScheduler);
						//console.log(scheduleScheduler.length);
						$("#scheduleScheduler").text((scheduleScheduler == "" || scheduleScheduler == null || scheduleScheduler == "null")?"":scheduleScheduler);
						$("#scheduleRsrvDate").text((scheduleRsrvDate == "null ~ null" || scheduleRsrvDate == " ~ ")?"":scheduleRsrvDate);
						$("#camp_term_cd").val(result.bo.camp_term_cd);
						$("#camp_end_dt").val(result.bo.camp_end_dt);
						$("#channel_priority_yn").val(result.bo.channel_priority_yn);
						$("#minDispDt").val(result.bo.minDispDt);
					} else {
						alert("에러가 발생하였습니다.");
					}
				}
			},
			beforeSend:function(){
			},
			complete:function(){
			},
			error: function(result, option) {
				alert("에러가 발생하였습니다.");
			}
		});
	}
	
	/* 조회조건 선택시 재조회 */
	function fn_selectSearchType(){
		fn_searchScheduleList($("#scheduleCampaignId").val());
	}
	
	/* 선택 삭제 */
	function fn_delete(){
		if ($("input:checkbox[name='CHK_DATE']:checked").length == 0){
			alert("삭제할 일정을 선택하세요");
			return;
		}
		if (!confirm($("input:checkbox[name='CHK_DATE']:checked").length + "건을 삭제 하시겠습니까?")){
			return;
		}
		jQuery.ajax({
			url           : '${staticPATH }/deleteScheduleList.do',
			dataType      : "JSON",
			scriptCharset : "UTF-8",
			async         : true,
			type          : "POST",
			data          : $("#formSchedule").serialize(),
			success: function(result, option) {
				if (option=="success"){
					alert("일정이 삭제 되었습니다");
					fn_selectSearchType();
				} else {
					alert("에러가 발생하였습니다.");
				}
			},
			beforeSend:function(){
			},
			complete:function(){
			},
			error: function(result, option) {
				alert("에러가 발생하였습니다.");
			}
		});
	}
	
	/* 전체 삭제 */
	function fn_deleteAll(){
		if (!confirm("전체 삭제 하시겠습니까?\n(이미 실행된 일정은 삭제되지 않습니다)")){
			return;
		}
		jQuery.ajax({
			url           : '${staticPATH }/deleteScheduleListAll.do',
			dataType      : "JSON",
			scriptCharset : "UTF-8",
			async         : true,
			type          : "POST",
			data          : $("#formSchedule").serialize(),
			success: function(result, option) {
				if (option=="success"){
					alert("전체 일정이 삭제 되었습니다");
					fn_selectSearchType()
				} else {
					alert("에러가 발생하였습니다.");
				}
			},
			beforeSend:function(){
			},
			complete:function(){
			},
			error: function(result, option) {
				alert("에러가 발생하였습니다.");
			}
		});
	}
	
	function fn_multi_save(){
		if (confirm("CI Studio 에서 스케쥴링\n\n등록을 완료 했습니까?"))  {
			jQuery.ajax({
				//url           : '${staticPATH }/multiCistudioSave.do',
				url           : '/SASStoredProcess/do?_program=%2FCM_META%2F41.STP%2F412.STP%2Fupt_channel&campaignid='+$("#scheduleCampaignId").val(),
				dataType      : "json",
				//jsonpCallback : "myCallback",
				//async         : true,
				//type          : "GET",
				//data          : $("#formSchedule").serialize(),
				success: function(result, option) {
					if (option=="success"){
						//console.log(result);
						//console.log(result.length);
						var tmpArr = new Array();
						//console.log(tmpArr);
						//console.log(tmpArr.length);
						// sas call 이후 데이터 처리
						if (result.length > 0) {
							jQuery.ajax({
								url           : '${staticPATH }/multiCistudioSave.do',
								dataType      : "json",
								async         : true,
								type          : "GET",
								data          : $("#formSchedule").serialize(),
								success: function(result1, option1) {
									if (option1=="success"){
										alert("정상적으로 처리 되었습니다.");
										fn_campaignInfoAll($("#CAMPAIGNID").val());
									} else {
										alert("에러가 발생하였습니다.");
									}
								},
								beforeSend:function(){
								},
								complete:function(){
								},
								error: function(result1, option1) {
									alert("에러가 발생하였습니다.");
								}
							});
						} else {
							alert("CI Studio 스케쥴링 정보를 확인할수 없습니다.\n\n관리자에 문의 해주세요.");
						}
					} else {
						alert("에러가 발생하였습니다.");
					}
				},
				beforeSend:function(){
				},
				complete:function(){
				},
				error: function(result, option) {
				  alert("에러가 발생하였습니다.");
				}
			});
		}
	}
	
	function campaignStop(){
		if (confirm("캠페인을 중지하시겠습니까?"))  {
			jQuery.ajax({
				url           : '${staticPATH }/campaignStop.do?CAMPAIGNCODE=' + $("#scheduleCAMPAIGNCODE").val(),
				dataType      : "JSON",
				scriptCharset : "UTF-8",
				async         : true,
				type          : "GET",
				//data          : $("#formSchedule").serialize(),
				success: function(result, option) {
					if (option=="success"){
						alert("캠페인 취소되었습니다.");
						fn_campaignInfoAll($("#CAMPAIGNID").val());
					} else {
						alert("에러가 발생하였습니다.");
					}
				},
				beforeSend:function(){
				},
				complete:function(){
				},
				error: function(result, option) {
				  alert("에러가 발생하였습니다.");
				}
			});
		}
	}
	
	function _test_channelMobile() {
		if (!true) {
			alert("_test_channelMobile()");
		}
		pop = window.open('', 'POP_TEST_CHANNEL', 'top=50,left=80, location=no,status=no,toolbar=no,scrollbars=yes');
		frmChannel.action = "${staticPATH }/channel/_test_channelMobile.do";
		frmChannel.target = "POP_TEST_CHANNEL";
		frmChannel.method = "POST";
		frmChannel.submit();
		pop.focus();
	}
</script>
<!-- END SCRIPT -->


<!--PAGE CONTENT -->
<div id="content" style="width:100%; height100%;">
	<!--BLOCK SECTION -->
	<div class="row" style="width:100%; height100%;">
		<div class="col-lg-1"></div>
		<div class="col-lg-10">
			<div class="col-md-10 page-header" style="margin-top:0px;">
				<h3>캠페인 리스트</h3>
			</div>
			<div class="col-md-2 page-header" style="margin-top:31px;">
				<button type="button" class="btn btn-success btn-xs pull-right" onclick="window.open('/SASCampaign/contents/CampaignContent.do?offercode=ALL&channelcode=ALL','contentsmapping','');" style="margin-bottom:3px;" >
					<i class="fa fa-plus" aria-hidden="true"></i> 컨텐츠 매핑
				</button>
			</div>
			<form name="form" id="form" method="post">
				<input type="hidden" id="selectPageNo" name="selectPageNo"  value="${selectPageNo}" />
				<input type="hidden" id="CampaignId" name="CampaignId" value="" />
				<input type="hidden" id="NOTICE_NO" name="NOTICE_NO"  value="" />
				<input type="hidden" id="TREE_VALUE" name="TREE_VALUE"  value="" />
				<input type="hidden" id="CELLID" name="CELLID" value="" />
				<input type="hidden" id="OFFERID" name="OFFERID" value="" />
				<!-- List -->
				<div class="col-md-3" style="height:320px">
					<button type="button" class="btn btn-warning btn-xs" id="expandAllBtn" onclick="return false;" style="margin-bottom:3px;" >
						<i class="fa fa-plus" aria-hidden="true"></i> 모두열기
					</button>
					<button type="button" class="btn btn-warning btn-xs pull-right" id="collapseAllBtn" onclick="return false;" style="margin-bottom:3px;" >
						<i class="fa fa-minus" aria-hidden="true"></i> 모두닫기
					</button>
					<ul id="tree" class="ztree"></ul>
				</div>
				<div class="col-md-9" style="border: 1px solid #DDDDDD;margin:0px;padding:0px;">
					<table class="table table-striped table-hover table-condensed" border="0" cellpadding="0" cellspacing="0" style="margin:0px;padding:0px;">
						<colgroup>
							<col width="13%"/>
							<col width=""/>
							<!-- <col width=""/> -->
							<col width="13%"/>
							<col width="18%"/>
						</colgroup>
						<thead>
							<tr class="info">
								<th style="text-align:center;">캠페인코드</th>
								<th style="text-align:center;">캠페인 명</th>
								<!-- <th style="text-align:center;">설명</th> -->
								<th style="text-align:center;">소유자</th>
								<th style="text-align:center;">최근실행</th>
							</tr>
						</thead>
						<tbody></tbody>
					</table>
					<div id="table" style="overflow-x: hidden; overflow-y: auto; width:100%; height:311px;margin-top:0px;">
						<table id="campaignList" class="table table-striped table-hover table-condensed" width="100%" border="0" cellpadding="0" cellspacing="0">
							<colgroup>
								<col width="13%"/>
								<col width=""/>
								<!-- <col width=""/> -->
								<col width="13%"/>
								<col width="18%"/>
							</colgroup>
							<tbody></tbody>
						</table>
						<div id="search_layer"></div>
					</div>
				</div>
			</form>
			<div id="optionDiv" class="col-md-12" style="display:none;margin-top:15px;margin-right:0px;padding-right:0px;">
				<div style="display:flex">
					<div class="col-md-7" >
						<ul id="myTab" class="nav nav-tabs" role="tablist">
							<li role="presentation" class="active">
								<a data-target="#summary" id="home-tab" role="tab" data-toggle="tab" aria-controls="summary" aria-expanded="true">
									<i class="fa fa-info"></i> 요 약
								</a>
							</li>
							<li role="presentation" class="">
								<a data-target="#property" id="home-tab" role="tab" data-toggle="tab" aria-controls="property" aria-expanded="true">
									<i class="fa fa-cog" aria-hidden="true"></i> 속 성
								</a>
							</li>
							<li role="presentation" class="">
								<a data-target="#offer" role="tab" id="profile-tab" data-toggle="tab" aria-controls="offer" aria-expanded="false">
									<i class="fa fa-filter"></i> 오 퍼
								</a>
							</li>
							<li role="presentation" class="">
								<a data-target="#channel" role="tab" id="profile-tab" data-toggle="tab" aria-controls="channel" aria-expanded="false">
									<i class="fa fa-comments-o"></i> 채 널 <!-- button onclick="_test_channelMobile()">BTN</button -->
								</a>
							</li>
							<li role="presentation" class="">
								<a data-target="#schedule" role="tab" id="profile-tab" data-toggle="tab" aria-controls="schedule" aria-expanded="false">
									<i class="fa fa-calendar"></i> 일 정
								</a>
							</li>
						</ul>
					</div>

					<!-- <div class="push-right" style="flex-basis: 400px;"></div> -->
				</div>
				<div id="myTabContent" class="tab-content">
					<input type="hidden" id="CAMPAIGNID" name="CAMPAIGNID" value="" />
<!-- 요약 탭 -->
					<div role="tabpanel" class="tab-pane fade active in" id="summary" aria-labelledby="profile-tab">
						<div id="table">
							<table class="table table-striped table-hover table-condensed table-bordered">
								<colgroup>
									<col width="20%" />
									<col width="80%" />
								</colgroup>
								<tr>
									<td class="info">캠페인명</td>
									<td class="tbtd_content">
										<span id="CAMPAIGNNAME_SUMMARY"></span>
									</td>
								</tr>
								<tr>
									<td class="info">캠페인코드</td>
									<td class="tbtd_content">
										<span id="CAMPAIGNCODE_SUMMARY"></span>
									</td>
								</tr>
								<tr>
									<td class="info">캠페인구분</td>
									<td class="tbtd_content">
										<span id="CAMPAIGNGUBUN"></span>
									</td>
								</tr>
								<tr>
									<td class="info">캠페인상세</td>
									<td class="tbtd_content">
										<span id="CAMPAIGN_DETAIL"></span>
									</td>
								</tr>
								<tr>
									<td class="info">캠페인종류</td>
									<td class="tbtd_content">
										<span id="CAMPAIGNTYPE"></span>
									</td>
								</tr>
								<tr>
									<td class="info">캠페인목적</td>
									<td class="tbtd_content">
										<span id="CAMPAIGN_OFFER_COST_GUBUN"></span>
									</td>
								</tr>
								<tr>
									<td class="info">데이터전송방식</td>
									<td class="tbtd_content">
										<span id="SENDDATETYPE"></span>
									</td>
								</tr>
							</table>
						</div>
					</div>
<!-- 속성 탭 -->
					<div role="tabpanel" class="tab-pane fade" id="property" aria-labelledby="home-tab">
						<!--
						<div class="col-md-12" style="text-align:right;margin-bottom:10px;">
							<button type="button" class="btn btn-warning btn-sm" id="propertyEdit" >
							 <i class="fa fa-pencil" aria-hidden="true"></i> 편 집
							</button>
							< !--  data-toggle="modal" href="/campaign/property.do" data-target="#modal-testNew" -- >
						</div>
						-->
						<div id="table">
							<table class="table table-striped table-hover table-condensed table-bordered">
								<colgroup>
									<col width="15%"/>
									<col width="35%"/>
									<col width="15%"/>
									<col width="35%"/>
								</colgroup>
								<tr>
									<td class="info">캠페인명</td>
									<td class="tbtd_content">
										<span id = "CAMPAIGNNAME"></span>
									</td>
									<td class="info">캠페인코드</td>
									<td class="tbtd_content">
										<span id = "CAMPAIGNCODE"></span>
									</td>
								</tr>
								<tr>
									<td class="info">캠페인기간</td>
									<td class="tbtd_content" colspan="3">
										<div style="display:inline;" id="cmpgnDtType1" style="display:none;">
											<span id = "CAMP_BGN_DT1"></span>
											<span id = "CAMP_BGN_DT2"></span> 시
											<span id = "CAMP_BGN_DT3"></span> 분
											~
											<span id = "CAMP_END_DT1"></span>
											<span id = "CAMP_END_DT2"></span> 시
											<span id = "CAMP_END_DT3"></span> 분
										</div>
										<div style="margin-top: 5px;" id="cmpgnDtType2" style="display:none;">
											전송일로 부터<span id = "CAMP_TERM_DAY"></span> 일 까지
										</div>
									</td>
								</tr>
								<tr>
									<td class="info">대상수준</td>
									<td class="tbtd_content">
										<span id ="AUDIENCE_NM"></span>
									</td>
									<td class="info">데이터전송방식</td>
									<td class="tbtd_content">
										<span id ="MANUAL_TRANS_NM"></span>
									</td>
								</tr>
								<tr>
									<td class="info">오퍼자동<br/>적용여부</td>
									<td class="tbtd_content">
										<span id ="OFFER_DIRECT_YN"></span>
									</td>
									<td class="info">채널우선순위적용</td>
									<td class="tbtd_content">
										<span id ="CHANNEL_PRIORITY_YN"></span>
									</td>
								</tr>
								<tr>
									<td class="info">등록자</td>
									<td class="tbtd_content">
										<span id ="CREATE_NM"></span>
									</td>
									<td class="info">등록일시</td>
									<td class="tbtd_content">
										<span id ="CREATE_DT"></span>
									</td>
								</tr>
								<tr>
									<td class="info">수정자</td>
									<td class="tbtd_content">
										<span id ="UPDATE_NM"></span>
									</td>
									<td class="info">수정일시</td>
									<td class="tbtd_content">
										<span id ="UPDATE_DT"></span>
									</td>
								</tr>
							</table>
						</div>
					</div>
<!-- 오퍼 탭 -->
					<div role="tabpanel" class="tab-pane fade" id="offer" aria-labelledby="profile-tab">
						<!--
						<div class="col-md-12" style="text-align:right;margin-bottom:10px;">
							<button type="button" class="btn btn-warning btn-sm" id="offerEdit">
								<i class="fa fa-pencil" aria-hidden="true"></i> 편 집
							</button>
						</div>
						-->
						<div id="offerList" >
						</div>
					</div>
<!-- 채널 탭 -->
					<div role="tabpanel" class="tab-pane fade" id="channel" aria-labelledby="profile-tab">
						<form name="frmChannel" id="frmChannel">
							<input type="hidden" id="ChannelCampaignId" name="CampaignId" value="" />
							<input type="hidden" id="ChannelCELLID" name="CELLID" value="" />
							<input type="hidden" id="CHANNEL_CD" name="CHANNEL_CD" value="" />
							<input type="hidden" id="DISABLED" name="DISABLED" value="Y" />
							<div id="table">
								<table class="table table-striped table-hover table-condensed table-bordered">
									<colgroup>
										<col width="15%"/>
										<col width="15%"/>
										<col width=""/>
										<col width="10%"/>
										<col width="10%"/>
									</colgroup>
									<tr class="info">
										<th style="text-align:center;">고객 세그먼트</th>
										<th style="text-align:center;">채널</th>
										<th style="text-align:center;">내용</th>
										<th style="text-align:center;">삭제</th>
										<th style="text-align:center;">추가</th>
									</tr>
								</table>
							</div>
							<div id="search_channel"></div>
						</form>
					</div>
<!-- 일정 탭 -->
					<div role="tabpanel" class="tab-pane fade" id="schedule" aria-labelledby="profile-tab">
						<form name="formSchedule" id="formSchedule">
							<input type="hidden" id="TO_DATE" name="TO_DATE" value="" />
							<input type="hidden" id="TO_DATE_P1" name="TO_DATE_P1" value="" />
							<input type="hidden" id="TO_DATE_P2" name="TO_DATE_P2" value="" />
							<input type="hidden" id="scheduleCAMPAIGNCODE" name="CAMPAIGNCODE" value="${bo.campaigncode}" />
							<input type="hidden" id="scheduleCampaignId" name="CampaignId" value="${bo.campaignid}" />
							<input type="hidden" id="selectPageNo" name="selectPageNo"  value="${selectPageNo}" />
							<input type="hidden" id="LIST_LENGTH" name="LIST_LENGTH"  value="0" />

							<input type="hidden" id="camp_term_cd" name="camp_term_cd"  value="" />
							<input type="hidden" id="camp_end_dt" name="camp_end_dt"  value="" />
							<input type="hidden" id="channel_priority_yn" name="channel_priority_yn"  value="" />
							<input type="hidden" id="minDispDt" name="minDispDt"  value="" />
							<div class="col-md-12" style="text-align:right;margin-bottom:10px;">
								<button type="button" class="btn btn-danger btn-sm" onclick="campaignStop();" id="campaignStopDiv">
									<i class="fa fa-plus" aria-hidden="true"></i> 캠페인 중지
								</button>
								<button type="button" class="btn btn-success btn-sm" onclick="fn_delete();" id="scheduleDel"><i class="fa fa-trash" aria-hidden="true"></i> 삭제</button>
								<!-- <button type="button" class="btn btn-success btn-sm" onclick="fn_deleteAll();"><i class="fa fa-trash-o" aria-hidden="true"></i> 전체삭제</button> -->
								<button type="button" class="btn btn-warning btn-sm" id="scheduleEdit"><i class="fa fa-pencil-square-o" aria-hidden="true"></i> 편집 </button>
								<div id="viewMultiDiv" style="height:100px;">
									<div class="col-md-10 text-center">
										<h4>CI Studio 에서 스케쥴링 등록을 먼저 실행해주세요!</h4>
									</div>
									<div class="col-md-2">
										<button type="button" class="btn btn-warning btn-sm" id="multiSaveBtn" onclick="fn_multi_save();" style="margin-bottom:5px;"><i class="fa fa-trash" aria-hidden="true"></i> 저장</button>
									</div>
								</div>
							</div>
							<div id="scheduleTable">
								<table class="table table-striped table-hover table-condensed table-bordered" width="100%" border="0" cellpadding="0" cellspacing="0">
									<colgroup>
										<col width="15%"/>
										<col width="35%"/>
										<col width="15%"/>
										<col width="35%"/>
									</colgroup>
									<tr>
										<td class="info">캠페인 코드/명</td>
										<td class="tbtd_content" id="scheduleCampaignCode"></td>
										<td class="info">일정구분</td>
										<td class="tbtd_content" id="scheduleScheduler"></td>
										<%-- <td class="info">플로차트 이름</td>
										<td class="tbtd_content">${bo.flowchartname}</td> --%>
									</tr>
									<tr>
										<td class="info">추출기간</td>
										<td class="tbtd_content" id="scheduleRsrvDate"></td>
										<td class="info">실행상태</td>
										<td class="tbtd_content">
											<select style="width: 70px;" id="SEARCH_TYPE" name="SEARCH_TYPE" >
												<option >전체</option>
												<option value="NULL">미실행</option>
												<option value="NOTNULL">실행</option>
											</select>
										</td>
									</tr> <!-- -->
									<tr id="scheduleAddTr">
										<td class="info">일정추가</td>
										<td class="tbtd_content" colspan="3">
											<div id="search2">
												<input type="text" id="RSRV_DT" name="RSRV_DT" class="txt" style="width:86px;" value="" readonly="readonly"/>
												<select style="width: 45px;" id="RSRV_HOUR" name="RSRV_HOUR" >
													<c:forEach var="val" varStatus="i" begin="08" end="20" step="1">
														<option value="${val}">
														<c:if test="${val < 10}">0</c:if><c:out value="${val}" />
														</option>
													</c:forEach>
												</select> 시
												<select style="width: 45px;" id="RSRV_MINUTE" name="RSRV_MINUTE">
													<c:forEach var="val" varStatus="i" begin="00" end="59" step="1">
														<option value="${val}">
														<c:if test="${val < 10}">0</c:if><c:out value="${val}" />
														</option>
													</c:forEach>
												</select> 분
												<button type="button" class="btn btn-success btn-sm" onclick="fn_validation();" id="scheduleAdd"><i class="fa fa-plus" aria-hidden="true"></i> 추가</button>
											</div>
										</td>
									</tr>
								</table>
							</div>
							<!-- List -->
							<div id="scheduleListDiv" style="overflow:scroll; width:100%; height:210px;margin-top:0px;">
								<table id="scheduleListTable" class="table table-striped table-hover table-condensed table-bordered" width="100%" border="0" cellpadding="0" cellspacing="0">
									<colgroup>
										<col width="3%"/>
										<col width="5%"/>
										<col width="15%"/>
										<col width="15%"/>
										<col width="15%"/>
										<col width="10%"/>
										<col width="11%"/>
										<col width="13%"/>
										<col width="13%"/>
									</colgroup>
									<thead>
									<tr class="info">
										<th style="text-align:center;" >No</th>
										<th style="text-align:center;">선택</th>
										<th style="text-align:center;">실행예정일시</th>
										<th style="text-align:center;">실행시작일시</th>
										<th style="text-align:center;">실행종료일시</th>
										<th style="text-align:center;">실행상태</th>
										<th style="text-align:center;">상태상세</th>
										<th style="text-align:center;">등록자ID</th>
										<th style="text-align:center;">등록일시</th>
									</tr>
									</thead>
									<tbody></tbody>
								</table>
							</div>
							<!-- <div id="search_layer_schedule"></div> -->
							<!-- <div id="paging_layer" class="s_paging"></div> -->
							<!-- /List -->
							<table border="0" cellpadding="0" cellspacing="0"><tr><td height="20"></td></table>
						</form>
					</div>
				</div>
			</div>
		</div>
	</div>
	<div class="col-lg-1"></div>
	<!-- END BLOCK SECTION -->

	<div class="col-lg-3"></div>
</div>
<!-- END PAGE CONTENT -->


<div id="modal-testNew" class="modal fade" tabindex="-1" role="dialog" aria-labelledby="테스트정보 등록" aria-describedby="테스트 모달">
	<div class="modal-dialog" style="width:1200px;height:700px">
		<div class="modal-content">
		</div>
	</div>
</div>

<%@ include file="/WEB-INF/views/common/_footer.jsp"%>

