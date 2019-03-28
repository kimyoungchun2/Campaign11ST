package com.skplanet.sascm.controller;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.net.MalformedURLException;
import java.net.URL;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.annotation.Resource;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.codehaus.jackson.JsonNode;
import org.codehaus.jackson.map.ObjectMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.ModelMap;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.servlet.view.json.MappingJacksonJsonView;

import com.skplanet.sascm.object.CampaignChannelBO;
import com.skplanet.sascm.object.CampaignInfoBO;
import com.skplanet.sascm.object.ChannelBO;
import com.skplanet.sascm.object.UaextCodeDtlBO;
import com.skplanet.sascm.object.UaextVariableBO;
import com.skplanet.sascm.object.UsmUserBO;
import com.skplanet.sascm.service.CampaignInfoService;
import com.skplanet.sascm.service.ChannelService;
import com.skplanet.sascm.service.CommCodeService;
import com.skplanet.sascm.service.VariableService;
import com.skplanet.sascm.util.Common;
import com.skplanet.sascm.util.Flag;

/**
 * ChannelController
 *
 * @author 김일범
 * @since 2013-12-05
 * @version $Revision$
 */
@Controller
public class ChannelController {

	private final Log log = LogFactory.getLog(getClass());

	@Resource(name = "commCodeService")
	private CommCodeService commCodeService;

	@Resource(name = "channelService")
	private ChannelService channelService;

	@Resource(name = "variableService")
	private VariableService variableService;

	@Resource(name = "campaignInfoService")
	private CampaignInfoService campaignInfoService;

	//AJAX
	@Autowired
	private MappingJacksonJsonView jsonView;

	private ObjectMapper objectMapper = new ObjectMapper();
	
	/**
	 *
	 *
	 * @param request
	 * @param response
	 * @param modelMap
	 * @return
	 * @throws Exception
	 */
	@RequestMapping("/getChannelInfoList.do")
	public void getChannelInfoList(HttpServletRequest request, HttpServletResponse response, ModelMap modelMap, HttpSession session) throws Exception {
		UsmUserBO user = (UsmUserBO) session.getAttribute("ACCOUNT");

		Map<String, Object> map = new HashMap<String, Object>();

		//paramter
		log.info("=============================================");
		log.info("CampaignId   : " + request.getParameter("campaignid"));
		log.info("=============================================");

		//캠페인 정보 상세 조회
		map.put("CAMPAIGNID", Common.nvl(request.getParameter("campaignid"), ""));
		map.put("USER_ID", user.getId());

		//채널정보
		List<CampaignChannelBO> channel_list = channelService.getCampaignChannelList(map);

		//2. 대상수준이 PCID일경우 채널이 토스트배너인지 체크
		String channelValiChk = channelService.getCampaignChannelValiChk(map);

		//5. 대상수준이 DEVICE_ID 일 경우 모바일 앱 채널만 사용가능
		String channelValChkforMobile = channelService.getCampaignChannelValiChkforMobile(map);

		map.put("channel_list", channel_list);
		map.put("channelValiChk", channelValiChk);
		map.put("channelValChkforMobile", channelValChkforMobile);
		map.put("CAMPAIGNID", Common.nvl(request.getParameter("CampaignId"), ""));

		jsonView.render(map, request, response);
	}

	/**
	 * 채널 정보 페이지 호출
	 *
	 * @param request
	 * @param response
	 * @param modelMap
	 * @return
	 * @throws Exception
	 */
	@RequestMapping("/channel/channelInfo.do")
	public String pageChannelInfo(HttpServletRequest request, HttpServletResponse response, ModelMap modelMap, HttpSession session) throws Exception {
		//사용자 정보
		UsmUserBO user = (UsmUserBO) session.getAttribute("ACCOUNT");

		//채널 목록 조회
		Map<String, Object> map = new HashMap<String, Object>();
		map.put("codeId", "C011");
		map.put("USE_YN", "Y");
		List<UaextCodeDtlBO> channel_list = commCodeService.getCommCodeDtlList(map);

		//paramter
		log.info("=============================================");
		log.info("CampaignId   : " + request.getParameter("CampaignId"));
		log.info("CELLID       : " + request.getParameter("CELLID"));
		log.info("=============================================");

		//채널정보 조회
		map.put("CAMPAIGNID", Common.nvl(request.getParameter("CampaignId"), ""));
		map.put("CELLID", Common.nvl(request.getParameter("CELLID"), ""));

		ChannelBO bo = channelService.getChannelInfo(map);

		modelMap.addAttribute("channel_list", channel_list);
		modelMap.addAttribute("bo", bo);
		modelMap.addAttribute("user", user);

		return "channel/channelInfo";
	}

	/**
	 * 채널 Toast배너 페이지 호출
	 *
	 * @param request
	 * @param response
	 * @param modelMap
	 * @return
	 * @throws Exception
	 */
	@RequestMapping("/channel/channelToast.do")
	public String pageChannelToast(HttpServletRequest request, HttpServletResponse response, ModelMap modelMap, HttpSession session) throws Exception {
		//사용자 정보
		UsmUserBO user = (UsmUserBO) session.getAttribute("ACCOUNT");

		//채널 목록 조회
		Map<String, Object> map = new HashMap<String, Object>();
		map.put("codeId", "C011");
		map.put("USE_YN", "Y");
		List<UaextCodeDtlBO> channel_list = commCodeService.getCommCodeDtlList(map);

		//우선순위
		map.put("codeId", "C006");
		List<UaextCodeDtlBO> priority_rank = commCodeService.getCommCodeDtlList(map);

		//이벤트 타입
		map.put("codeId", "C008");
		List<UaextCodeDtlBO> evt_type = commCodeService.getCommCodeDtlList(map);

		//linkUrl
		map.put("codeId", "C017"); //MEM_NO 일때의 LinkUrl
		List<UaextCodeDtlBO> linkUrl = commCodeService.getCommCodeDtlList(map);

		//linkUrl
		map.put("codeId", "C021"); //PCID 일때의 LinkUrl
		List<UaextCodeDtlBO> linkUrl2 = commCodeService.getCommCodeDtlList(map);

		//사용자 변수
		map.put("SVARI_NAME", Common.nvl(request.getParameter("SVARI_NAME"), ""));
		map.put("SKEY_COLUMN", Common.nvl(request.getParameter("SKEY_COLUMN"), ""));
		List<UaextVariableBO> vri_list = variableService.getVariableList(map);

		//paramter
		log.info("=============================================");
		log.info("CampaignId   : " + request.getParameter("CampaignId"));
		log.info("CELLID       : " + request.getParameter("CELLID"));
		log.info("CHANNEL_CD   : " + request.getParameter("CHANNEL_CD"));
		log.info("=============================================");

		//채널정보 조회
		map.put("CAMPAIGNID", Common.nvl(request.getParameter("CampaignId"), ""));
		map.put("CELLID", Common.nvl(request.getParameter("CELLID"), ""));
		map.put("CHANNEL_CD", Common.nvl(request.getParameter("CHANNEL_CD"), ""));

		ChannelBO bo = channelService.getChannelDtlInfo(map);

		modelMap.addAttribute("channel_list", channel_list);
		modelMap.addAttribute("priority_rank", priority_rank);
		modelMap.addAttribute("vri_list", vri_list);
		modelMap.addAttribute("evt_type", evt_type);
		modelMap.addAttribute("linkUrl", linkUrl);
		modelMap.addAttribute("linkUrl2", linkUrl2);

		modelMap.addAttribute("bo", bo);
		modelMap.addAttribute("user", user);
		modelMap.addAttribute("CHANNEL_CD", request.getParameter("CHANNEL_CD"));
		modelMap.addAttribute("DISABLED", request.getParameter("DISABLED"));

		return "channel/channelToast";
	}

	/**
	 * 채널 Toast배너 미리보기
	 *
	 * @param request
	 * @param response
	 * @param modelMap
	 * @return
	 * @throws Exception
	 */
	@RequestMapping("/channel/channelToastPreview.do")
	public void pageChannelToastPreview(HttpServletRequest request, HttpServletResponse response, ModelMap modelMap) throws Exception {
		Map<String, Object> map = new HashMap<String, Object>();

		//paramter
		log.info("=============================================");
		log.info("TOAST_INPUT_MSG   : " + request.getParameter("TOAST_INPUT_MSG"));
		log.info("=============================================");

		String TOAST_MSG = Common.nvl(request.getParameter("TOAST_INPUT_MSG"), "");

		//사용자 변수 목록을 조회
		map.put("SVARI_NAME", Common.nvl(request.getParameter("SVARI_NAME"), ""));
		map.put("SKEY_COLUMN", Common.nvl(request.getParameter("SKEY_COLUMN"), ""));

		List<UaextVariableBO> vri_list = variableService.getVariableList(map);

		for (int i = 0; i < vri_list.size(); i++) { //Toast 메세지에 사용자변수가 사용되었는지 체크
			UaextVariableBO bo = vri_list.get(i);

			log.info("=============================================");
			String vari_name = "{" + bo.getVari_name() + "}";
			log.info("getVari_name   : " + vari_name);

			if (TOAST_MSG.indexOf(vari_name) > -1) { //변수가 존재할경우
				log.info("변수 존재함!");

				String[] arr = bo.getRef_table().split("\\.");
				String tmpTbl = "";
				if(arr.length > 0){
					tmpTbl =  arr[1];
				}else{
					tmpTbl =  arr[0];
				}
				//테스트용 데이터 조회
				map.put("REF_TABLE", tmpTbl);
				map.put("REF_COLUMN", bo.getRef_column());
				map.put("KEY_COLUMN", bo.getKey_column());
				map.put("MAX_BYTE", bo.getMax_byte());

				String preval = variableService.getVariablePreVal(map);
				log.info("조회된 변수값   : " + preval);

				//변수값 변경하기
				TOAST_MSG = TOAST_MSG.replaceAll("\\" + vari_name, preval);
				log.info("변경된 값   : " + TOAST_MSG);
			} else {
				log.info("변수 미존재..");
			}
			log.info("=============================================");
		}

		map.put("TOAST_INPUT_MSG", TOAST_MSG);

		jsonView.render(map, request, response);
	}

	/**
	 * 채널 Toast배너 정보 저장
	 *
	 * @param request
	 * @param response
	 * @param modelMap
	 * @return
	 * @throws Exception
	 */
	@RequestMapping("/setChannelToast.do")
	public void setChannelToast(HttpServletRequest request, HttpServletResponse response, ModelMap modelMap, HttpSession session) throws Exception {
		Map<String, Object> map = new HashMap<String, Object>();

		UsmUserBO user = (UsmUserBO) session.getAttribute("ACCOUNT");

		//paramter
		log.info("=============================================");
		log.info("CAMPAIGNID           : " + request.getParameter("CampaignId"));
		log.info("CAMPAIGNCODE         : " + request.getParameter("CAMPAIGNCODE"));
		log.info("FLOWCHARTID          : " + request.getParameter("FLOWCHARTID"));
		log.info("CELLID               : " + request.getParameter("CELLID"));
		log.info("CHANNEL_CD           : " + request.getParameter("CHANNEL_CD"));

		log.info("TOAST_TITLE          : " + request.getParameter("TOAST_TITLE"));
		log.info("TOAST_MSG            : " + request.getParameter("TOAST_MSG"));
		log.info("TOAST_INPUT_MSG      : " + request.getParameter("TOAST_INPUT_MSG"));
		log.info("TOAST_IMG_URL        : " + request.getParameter("TOAST_IMG_URL"));
		log.info("TOAST_LINK_URL       : " + request.getParameter("TOAST_LINK_URL"));
		log.info("TOAST_MSG_DESC       : " + request.getParameter("TOAST_MSG_DESC"));
		log.info("TOAST_PRIORITY_RNK   : " + request.getParameter("TOAST_PRIORITY_RNK"));
		log.info("TOAST_EVNT_TYP_CD    : " + request.getParameter("TOAST_EVNT_TYP_CD"));
		log.info("=============================================");

		String TOAST_MSG = Common.nvl(request.getParameter("TOAST_MSG"), "");

		//사용자 변수 목록을 조회
		map.put("SVARI_NAME", Common.nvl(request.getParameter("SVARI_NAME"), ""));
		map.put("SKEY_COLUMN", Common.nvl(request.getParameter("SKEY_COLUMN"), ""));

		List<UaextVariableBO> vri_list = variableService.getVariableList(map);

		int vai_cnt = 0;
		List<String> query_lsit0 = new ArrayList<String>();
		List<String> query_lsit1 = new ArrayList<String>();
		List<String> query_lsit2 = new ArrayList<String>();
		List<String> query_lsit3 = new ArrayList<String>();
		List<String> query_lsit4 = new ArrayList<String>();
		List<String> query_lsit5 = new ArrayList<String>(); //MAX BYTE

		for (int i = 0; i < vri_list.size(); i++) { //Toast 메세지에 사용자변수가 사용되었는지 체크
			UaextVariableBO bo = vri_list.get(i);

			log.info("=============================================");
			String vari_name = "{" + bo.getVari_name() + "}";
			log.info("getVari_name   : " + vari_name);

			if (TOAST_MSG.indexOf(vari_name) > -1) { //변수가 존재할경우 조회 쿼리를 만든다
				log.info("변수 존재함!");

				//테스트용 데이터 조회
				String VARI_NAME = bo.getVari_name();
				String REF_TABLE = bo.getRef_table();
				String REF_COLUMN = bo.getRef_column();
				String KEY_COLUMN = bo.getKey_column();
				String IF_NULL = bo.getIf_null();
				String MAX_LENGTH = bo.getMax_byte();

				query_lsit0.add(VARI_NAME);
				query_lsit1.add(REF_TABLE);
				query_lsit2.add(REF_COLUMN);
				query_lsit3.add(KEY_COLUMN);
				query_lsit4.add(IF_NULL);
				query_lsit5.add(MAX_LENGTH);

				vai_cnt++; //카운트 +1

				log.info("* VARI_NAME : " + VARI_NAME + " * REF_TABLE : " + REF_TABLE + " * REF_COLUMN : " + REF_COLUMN
						+ " * KEY_COLUMN : " + KEY_COLUMN + " * IF_NULL : " + IF_NULL + " * MAX_LENGTH : " + MAX_LENGTH);
			} else {
				log.info("변수 미존재..");
			}
			log.info("=============================================");
		}

		// 		조회쿼리를 생성하여 db에 저장한다(ex)
		//		SELECT T.MEM_NO, '이름=' || T1.NAME ||'#@#id=' || T2.CODE
		//		  FROM [TARGETTABLE] T0
		//		,(SELECT NAME FROM TABLE1) T1
		//		,(SELECT CODE FROM TABLE2) T2
		//		WHERE T0.MEM_NO = T1.KEY1(+)
		//		  AND T0.MEM_NO = T2.KEY2(+)

		String TOAST_MSG_QUERY = "";
		String TOAST_MSG_QUERY1 = ""; //SELECT T.MEM_NO,
		String TOAST_MSG_QUERY2 = ""; //[TARGETTABLE]
		String TOAST_MSG_QUERY3 = ""; //FROM
		String TOAST_MSG_QUERY4 = ""; //WHERE

		for (int i = 0; i < vai_cnt; i++) { //존재한 변수만큼 조회 쿼리를 만든다
			if (i == 0) { //최초
				TOAST_MSG_QUERY1 += "SELECT T.MEM_NO,";
				TOAST_MSG_QUERY1 += " '" + query_lsit0.get(i) + "=' || SUBSTRB(NVL(T" + i + "." + query_lsit2.get(i) + ", '"
						+ query_lsit4.get(i) + "'), 0," + query_lsit5.get(i) + ")";
				TOAST_MSG_QUERY2 += " FROM [TARGETTABLE] T";
				TOAST_MSG_QUERY3 += " , (SELECT * FROM " + query_lsit1.get(i) + ") T" + i;
				TOAST_MSG_QUERY4 += " WHERE T.MEM_NO = T" + i + "." + query_lsit3.get(i) + "(+)";
			} else {
				TOAST_MSG_QUERY1 += " ||'#@#" + query_lsit0.get(i) + "=' || SUBSTRB(NVL(T" + i + "." + query_lsit2.get(i) + ", '"
						+ query_lsit4.get(i) + "'), 0," + query_lsit5.get(i) + ")";
				TOAST_MSG_QUERY3 += " , (SELECT * FROM " + query_lsit1.get(i) + ") T" + i;
				TOAST_MSG_QUERY4 += " AND T.MEM_NO = T" + i + "." + query_lsit3.get(i) + "(+)";
			}
		}

		TOAST_MSG_QUERY = TOAST_MSG_QUERY1 + TOAST_MSG_QUERY2 + TOAST_MSG_QUERY3 + TOAST_MSG_QUERY4;

		log.info("=============================================");
		log.info("TOAST_MSG_QUERY ::: " + TOAST_MSG_QUERY);
		log.info("=============================================");

		//입력 값
		map.put("CAMPAIGNID", Common.nvl(request.getParameter("CampaignId"), ""));
		map.put("CAMPAIGNCODE", Common.nvl(request.getParameter("CAMPAIGNCODE"), ""));
		map.put("FLOWCHARTID", Common.nvl(request.getParameter("FLOWCHARTID"), ""));
		map.put("CELLID", Common.nvl(request.getParameter("CELLID"), ""));
		map.put("CHANNEL_CD", "TOAST"); //TOAST 배너
		map.put("TOAST_TITLE", Common.nvl(request.getParameter("TOAST_TITLE"), ""));
		map.put("TOAST_MSG", Common.nvl(request.getParameter("TOAST_MSG"), ""));
		map.put("TOAST_INPUT_MSG", Common.nvl(request.getParameter("TOAST_INPUT_MSG"), ""));
		map.put("TOAST_IMG_URL", Common.nvl(request.getParameter("TOAST_IMG_URL"), ""));
		map.put("TOAST_MSG_QUERY", Common.nvl(TOAST_MSG_QUERY, ""));
		map.put("TOAST_LINK_URL", Common.nvl(request.getParameter("TOAST_LINK_URL"), ""));
		map.put("TOAST_MSG_DESC", Common.nvl(request.getParameter("TOAST_MSG_DESC"), ""));
		map.put("TOAST_PRIORITY_RNK", Common.nvl(request.getParameter("TOAST_PRIORITY_RNK"), ""));
		map.put("TOAST_EVNT_TYP_CD", Common.nvl(request.getParameter("TOAST_EVNT_TYP_CD"), ""));
		map.put("CREATE_ID", user.getId());
		map.put("UPDATE_ID", user.getId());

		//캠페인의 상태체크(START일경우에는 수정못함)
		CampaignInfoBO bo = campaignInfoService.getCampaignInfo(map);
		String CMP_STATUS = Common.nvl(bo.getCamp_status_cd(), "");

		if (!CMP_STATUS.equals("START")) {
			//토스트 배너 정보 저장
			channelService.setChannelToast(map);
		}

		//캠페인 상태 리턴
		map.put("CMP_STATUS", CMP_STATUS);

		jsonView.render(map, request, response);
	}

	/**
	 * 채널 SMS 페이지 호출
	 *
	 * @param request
	 * @param response
	 * @param modelMap
	 * @return
	 * @throws Exception
	 */
	@RequestMapping("/channel/channelSms.do")
	public String pageChannelSms(HttpServletRequest request, HttpServletResponse response, ModelMap modelMap, HttpSession session) throws Exception {
		//사용자 정보
		UsmUserBO user = (UsmUserBO) session.getAttribute("ACCOUNT");

		Map<String, Object> map = new HashMap<String, Object>();

		//채널 목록 조회
		map.put("codeId", "C011");
		map.put("USE_YN", "Y");
		List<UaextCodeDtlBO> channel_list = commCodeService.getCommCodeDtlList(map);

		//우선순위
		map.put("codeId", "C006");
		List<UaextCodeDtlBO> priority_rank = commCodeService.getCommCodeDtlList(map);

		//SMS우선순위별발송시간
		map.put("codeId", "C026");
		List<UaextCodeDtlBO> priority_rank_sendtime = commCodeService.getCommCodeDtlList(map);

		//완료시 전달번호
		map.put("codeId", "C012");
		List<UaextCodeDtlBO> comp_list = commCodeService.getCommCodeDtlList(map);

		//CALLBACK 번호
		map.put("codeId", "C023");
		List<UaextCodeDtlBO> callback_list = commCodeService.getCommCodeDtlList(map);

		//연결페이지 구분
		map.put("codeId", "G006");
		List<UaextCodeDtlBO> smsSendPreferCd = commCodeService.getCommCodeDtlList(map);


		//사용자 변수
		map.put("SVARI_NAME", Common.nvl(request.getParameter("SVARI_NAME"), ""));
		map.put("SKEY_COLUMN", Common.nvl(request.getParameter("SKEY_COLUMN"), ""));
		List<UaextVariableBO> vri_list = variableService.getVariableList(map);

		//paramter
		log.info("=============================================");
		log.info("CampaignId   : " + request.getParameter("CampaignId"));
		log.info("CELLID       : " + request.getParameter("CELLID"));
		log.info("CHANNEL_CD   : " + request.getParameter("CHANNEL_CD"));
		log.info("=============================================");

		//채널정보 조회
		map.put("CAMPAIGNID", Common.nvl(request.getParameter("CampaignId"), ""));
		map.put("CELLID", Common.nvl(request.getParameter("CELLID"), ""));
		map.put("CHANNEL_CD", Common.nvl(request.getParameter("CHANNEL_CD"), ""));

		ChannelBO bo = channelService.getChannelDtlInfo(map);

		modelMap.addAttribute("channel_list", channel_list);
		modelMap.addAttribute("priority_rank", priority_rank);
		modelMap.addAttribute("priority_rank_sendtime", priority_rank_sendtime);
		//modelMap.addAttribute("campScheduleTime", Common.campScheduleTime);
		modelMap.addAttribute("smsSendPreferCd", smsSendPreferCd);

		modelMap.addAttribute("vri_list", vri_list);
		modelMap.addAttribute("comp_list", comp_list);
		modelMap.addAttribute("callback_list", callback_list);

		modelMap.addAttribute("bo", bo);
		modelMap.addAttribute("user", user);
		modelMap.addAttribute("CHANNEL_CD", request.getParameter("CHANNEL_CD"));
		modelMap.addAttribute("DISABLED", request.getParameter("DISABLED"));

		return "channel/channelSms";
	}

	/**
	 * 채널 SMS 미리보기
	 *
	 * @param request
	 * @param response
	 * @param modelMap
	 * @return
	 * @throws Exception
	 */
	@RequestMapping("/channelSmsPreview.do")
	public void channelSmsPreview(HttpServletRequest request, HttpServletResponse response, ModelMap modelMap) throws Exception {
		Map<String, Object> map = new HashMap<String, Object>();

		//paramter
		log.info("=============================================");
		log.info("SMS_INPUT_MSG   : " + request.getParameter("SMS_INPUT_MSG"));
		log.info("=============================================");

		String SMS_MSG = Common.nvl(request.getParameter("SMS_INPUT_MSG"), "");

		//사용자 변수 목록을 조회
		map.put("SVARI_NAME", Common.nvl(request.getParameter("SVARI_NAME"), ""));
		map.put("SKEY_COLUMN", Common.nvl(request.getParameter("SKEY_COLUMN"), ""));

		List<UaextVariableBO> vri_list = variableService.getVariableList(map);

		for (int i = 0; i < vri_list.size(); i++) { //Toast 메세지에 사용자변수가 사용되었는지 체크
			UaextVariableBO bo = vri_list.get(i);

			log.info("=============================================");
			String vari_name = "{" + bo.getVari_name() + "}";
			log.info("getVari_name   : " + vari_name);

			if (SMS_MSG.indexOf(vari_name) > -1) { //변수가 존재할경우
				log.info("변수 존재함!");

				//테스트용 데이터 조회
				map.put("REF_TABLE", bo.getRef_table());
				map.put("REF_COLUMN", bo.getRef_column());
				map.put("KEY_COLUMN", bo.getKey_column());
				map.put("MAX_BYTE", bo.getMax_byte());

				String preval = variableService.getVariablePreVal(map);
				log.info("조회된 변수값   : " + preval);

				//변수값 변경하기
				SMS_MSG = SMS_MSG.replaceAll("\\" + vari_name, preval);
				log.info("변경된 값   : " + SMS_MSG);
			} else {
				log.info("변수 미존재..");
			}
			log.info("=============================================");
		}

		map.put("SMS_INPUT_MSG", SMS_MSG);

		jsonView.render(map, request, response);
	}

	/**
	 * 채널 SMS ShortURL가져오기
	 *
	 * @param request
	 * @param response
	 * @param modelMap
	 * @return
	 * @throws Exception
	 */
	@RequestMapping("/channelSmsShortUrl.do")
	public void channelSmsShortUrl(HttpServletRequest request, HttpServletResponse response, ModelMap modelMap) throws Exception {
		Map<String, Object> map = new HashMap<String, Object>();

		//paramter
		log.info("=============================================");
		log.info("SMS_LONGURL   : " + request.getParameter("SMS_LONGURL"));

		String SMS_LONGURL = "http://bizapi.11st.co.kr/jsp/message/get_callback_url.jsp?domain=11st.kr&url="
				+ Common.nvl(request.getParameter("SMS_LONGURL"), "");

		log.info("SMS_LONGURL2   : " + SMS_LONGURL);
		log.info("=============================================");

		//url 가져오기
		URL url = null;
		String line = "";
		BufferedReader input = null;
		String ShortUrl = "";

		try {
			url = new URL(SMS_LONGURL);
			input = new BufferedReader(new InputStreamReader(url.openStream()));
			while ((line = input.readLine()) != null) {
				ShortUrl += line;
			}

			log.info("=============================================");
			log.info("SHORT_URL   : " + ShortUrl);
			log.info("=============================================");
		} catch (MalformedURLException mue) {
			log.info("잘못되 URL입니다. 사용법 : java URLConn http://hostname/path]");
		} catch (IOException ioe) {
			log.info("IOException " + ioe);
			ioe.printStackTrace();
		}

		map.put("SHORT_URL", ShortUrl);

		jsonView.render(map, request, response);
	}

	/**
	 * 채널 SMS 정보 저장
	 *
	 * @param request
	 * @param response
	 * @param modelMap
	 * @return
	 * @throws Exception
	 */
	@RequestMapping("setChannelSms.do")
	public void setChannelSms(HttpServletRequest request, HttpServletResponse response, ModelMap modelMap, HttpSession session) throws Exception {
		Map<String, Object> map = new HashMap<String, Object>();

		UsmUserBO user = (UsmUserBO) session.getAttribute("ACCOUNT");

		//paramter
		log.info("=============================================");
		log.info("CAMPAIGNID           : " + request.getParameter("CampaignId"));
		log.info("CAMPAIGNCODE         : " + request.getParameter("CAMPAIGNCODE"));
		log.info("FLOWCHARTID          : " + request.getParameter("FLOWCHARTID"));
		log.info("CELLID               : " + request.getParameter("CELLID"));
		log.info("CHANNEL_CD           : " + request.getParameter("CHANNEL_CD"));

		log.info("SMS_MSG              : " + request.getParameter("SMS_MSG"));
		log.info("SMS_PRIORITY_RNK     : " + request.getParameter("SMS_PRIORITY_RNK"));
		log.info("SMS_DISP_TIME        : " + request.getParameter("SMS_DISP_TIME"));
		log.info("SMS_LONGURL          : " + request.getParameter("SMS_LONGURL"));
		log.info("SMS_SHORTURL         : " + request.getParameter("SMS_SHORTURL"));
		log.info("SMS_DISP_DT          : " + request.getParameter("SMS_DISP_DT"));
		log.info("SMS_CALLBACK         : " + request.getParameter("SMS_CALLBACK"));
		log.info("SMS_RETURNCALL       : " + request.getParameterValues("SMS_RETURNCALL"));
		log.info("SMS_SEND_PREFER_CD       : " + request.getParameter("SMS_SEND_PREFER_CD"));
		log.info("=============================================");

		String SMS_MSG = Common.nvl(request.getParameter("SMS_MSG"), "");

		//사용자 변수 목록을 조회
		map.put("SVARI_NAME", Common.nvl(request.getParameter("SVARI_NAME"), ""));
		map.put("SKEY_COLUMN", Common.nvl(request.getParameter("SKEY_COLUMN"), ""));

		List<UaextVariableBO> vri_list = variableService.getVariableList(map);

		int vai_cnt = 0;
		List<String> query_lsit0 = new ArrayList<String>(); //변수명
		List<String> query_lsit1 = new ArrayList<String>(); //참조테이블
		List<String> query_lsit2 = new ArrayList<String>(); //참조컬럼
		List<String> query_lsit3 = new ArrayList<String>(); //키컬럼
		List<String> query_lsit4 = new ArrayList<String>(); //널값일경우
		List<String> query_lsit5 = new ArrayList<String>(); //MAX BYTE

		for (int i = 0; i < vri_list.size(); i++) { //SMS 메세지에 사용자변수가 사용되었는지 체크
			UaextVariableBO bo = vri_list.get(i);

			log.info("=============================================");
			String vari_name = "{" + bo.getVari_name() + "}";
			log.info("getVari_name   : " + vari_name);

			if (SMS_MSG.indexOf(vari_name) > -1) { //변수가 존재할경우 조회 쿼리를 만든다
				log.info("변수 존재함!");

				//테스트용 데이터 조회
				String VARI_NAME = bo.getVari_name();
				String REF_TABLE = bo.getRef_table();
				String REF_COLUMN = bo.getRef_column();
				String KEY_COLUMN = bo.getKey_column();
				String IF_NULL = bo.getIf_null();
				String MAX_LENGTH = bo.getMax_byte();

				query_lsit0.add(VARI_NAME);
				query_lsit1.add(REF_TABLE);
				query_lsit2.add(REF_COLUMN);
				query_lsit3.add(KEY_COLUMN);
				query_lsit4.add(IF_NULL);
				query_lsit5.add(MAX_LENGTH);

				vai_cnt++; //카운트 +1

				log.info("* VARI_NAME : " + VARI_NAME + " * REF_TABLE : " + REF_TABLE + " * REF_COLUMN : " + REF_COLUMN
						+ " * KEY_COLUMN : " + KEY_COLUMN + " * IF_NULL : " + IF_NULL + " * MAX_LENGTH : " + MAX_LENGTH);
			} else {
				log.info("변수 미존재..");
			}
			log.info("=============================================");
		}

		// 		조회쿼리를 생성하여 db에 저장한다(ex)
		//		SELECT T.MEM_NO, T1.NAME || '님 반갑습니다 ' || T2.RANK || '등급이 되셨습니다'
		//		  FROM [TARGETTABLE] T
		//		,(SELECT NAME FROM TABLE1) T1
		//		,(SELECT CODE FROM TABLE2) T2
		//		WHERE T0.MEM_NO = T1.KEY1(+)
		//		  AND T0.MEM_NO = T2.KEY2(+)

		String SMS_MSG_QUERY = "";
		String SMS_MSG_QUERY1 = ""; //SELECT T.MEM_NO,
		String SMS_MSG_QUERY2 = ""; //[TARGETTABLE]
		String SMS_MSG_QUERY3 = ""; //FROM
		String SMS_MSG_QUERY4 = ""; //WHERE

		for (int i = 0; i < vai_cnt; i++) { //존재한 변수만큼 조회 쿼리를 만든다
			if (i == 0) { //최초
				SMS_MSG_QUERY1 += "SELECT T.MEM_NO, '" + SMS_MSG + "'";
				SMS_MSG_QUERY1 = SMS_MSG_QUERY1.replaceAll("\\{" + query_lsit0.get(i) + "}", "' || SUBSTRB(NVL(T" + i + "."
						+ query_lsit2.get(i) + ", '" + query_lsit4.get(i) + "'), 0," + query_lsit5.get(i) + ") || '");
				SMS_MSG_QUERY2 += " FROM [TARGETTABLE] T";
				SMS_MSG_QUERY3 += " , (SELECT * FROM " + query_lsit1.get(i) + ") T" + i;
				SMS_MSG_QUERY4 += " WHERE T.MEM_NO = T" + i + "." + query_lsit3.get(i) + "(+)";
			} else {
				SMS_MSG_QUERY1 = SMS_MSG_QUERY1.replaceAll("\\{" + query_lsit0.get(i) + "}", "' || SUBSTRB(NVL(T" + i + "."
						+ query_lsit2.get(i) + ", '" + query_lsit4.get(i) + "'), 0," + query_lsit5.get(i) + ") || '");
				SMS_MSG_QUERY3 += " , (SELECT * FROM " + query_lsit1.get(i) + ") T" + i;
				SMS_MSG_QUERY4 += " AND T.MEM_NO = T" + i + "." + query_lsit3.get(i) + "(+)";
			}
		}

		SMS_MSG_QUERY = SMS_MSG_QUERY1 + SMS_MSG_QUERY2 + SMS_MSG_QUERY3 + SMS_MSG_QUERY4;

		log.info("=============================================");
		log.info("SMS_MSG_QUERY ::: " + SMS_MSG_QUERY);
		log.info("=============================================");

		//입력 값
		map.put("CAMPAIGNID", Common.nvl(request.getParameter("CampaignId"), ""));
		map.put("CAMPAIGNCODE", Common.nvl(request.getParameter("CAMPAIGNCODE"), ""));
		map.put("FLOWCHARTID", Common.nvl(request.getParameter("FLOWCHARTID"), ""));
		map.put("CELLID", Common.nvl(request.getParameter("CELLID"), ""));
		map.put("CHANNEL_CD", "SMS"); //SMS

		map.put("SMS_MSG", Common.nvl(request.getParameter("SMS_MSG"), ""));
		map.put("SMS_MSG_QUERY", Common.nvl(SMS_MSG_QUERY, ""));
		map.put("SMS_PRIORITY_RNK", Common.nvl(request.getParameter("SMS_PRIORITY_RNK"), ""));

		map.put("SMS_DISP_TIME", Common.nvl(request.getParameter("SMS_DISP_TIME"), ""));

		map.put("SMS_SEND_PREFER_CD", Common.nvl(request.getParameter("SMS_SEND_PREFER_CD"), ""));

		map.put("SMS_LONGURL", Common.nvl(request.getParameter("SMS_LONGURL"), ""));
		map.put("SMS_SHORTURL", Common.nvl(request.getParameter("SMS_SHORTURL"), ""));
		map.put("SMS_DISP_DT", Common.nvl(request.getParameter("SMS_DISP_DT"), ""));
		map.put("SMS_CALLBACK", Common.nvl(request.getParameter("SMS_CALLBACK"), ""));
		String SMS_RETURNCALLS[] = request.getParameterValues("SMS_RETURNCALL");
		String SMS_RETURNCALL = "";
		for (int i = 0; i < SMS_RETURNCALLS.length; i++) {
			if (i == 0) {
				SMS_RETURNCALL = SMS_RETURNCALLS[i];
			} else {
				SMS_RETURNCALL += ";" + SMS_RETURNCALLS[i];
			}
		}
		map.put("SMS_RETURNCALL", SMS_RETURNCALL);
		map.put("CREATE_ID", user.getId());
		map.put("UPDATE_ID", user.getId());

		//캠페인의 상태체크(START일경우에는 수정못함)
		CampaignInfoBO bo = campaignInfoService.getCampaignInfo(map);
		String CMP_STATUS = Common.nvl(bo.getCamp_status_cd(), "");

		if (!CMP_STATUS.equals("START")) {
			//SMS 정보 저장
			channelService.setChannelSms(map);
		}

		//캠페인 상태 리턴
		map.put("CMP_STATUS", CMP_STATUS);

		jsonView.render(map, request, response);
	}

	/**
	 * 채널 EMAIL 페이지 호출
	 *
	 * @param request
	 * @param response
	 * @param modelMap
	 * @return
	 * @throws Exception
	 */
	@RequestMapping("/channel/channelEmail.do")
	public String pageChannelEmail(HttpServletRequest request, HttpServletResponse response, ModelMap modelMap, HttpSession session) throws Exception {
		//사용자 정보
		UsmUserBO user = (UsmUserBO) session.getAttribute("ACCOUNT");

		Map<String, Object> map = new HashMap<String, Object>();

		//채널 목록 조회
		map.put("codeId", "C011");
		map.put("USE_YN", "Y");
		List<UaextCodeDtlBO> channel_list = commCodeService.getCommCodeDtlList(map);

		//우선순위
		map.put("codeId", "C006");
		List<UaextCodeDtlBO> priority_rank = commCodeService.getCommCodeDtlList(map);

		//EMAIL우선순위별발송시간
		map.put("codeId", "C027");
		List<UaextCodeDtlBO> priority_rank_sendtime = commCodeService.getCommCodeDtlList(map);

		//사용자 변수 목록을 조회
		map.put("codeId", "C013");
		List<UaextCodeDtlBO> vri_list = commCodeService.getCommCodeDtlList(map);

		//paramter
		log.info("=============================================");
		log.info("CampaignId   : " + request.getParameter("CampaignId"));
		log.info("CELLID       : " + request.getParameter("CELLID"));
		log.info("CHANNEL_CD   : " + request.getParameter("CHANNEL_CD"));
		log.info("=============================================");

		//채널정보 조회
		map.put("CAMPAIGNID", Common.nvl(request.getParameter("CampaignId"), ""));
		map.put("CELLID",     Common.nvl(request.getParameter("CELLID"), ""));
		map.put("CHANNEL_CD", Common.nvl(request.getParameter("CHANNEL_CD"), ""));

		ChannelBO bo = channelService.getChannelDtlInfo(map);

		if ( bo.getEmail_subject() != null ){
			bo.setEmail_subject(bo.getEmail_subject().replaceAll("\"", "&quot;"));
		}

		modelMap.addAttribute("channel_list", channel_list);
		modelMap.addAttribute("priority_rank", priority_rank);
		modelMap.addAttribute("priority_rank_sendtime", priority_rank_sendtime);
		modelMap.addAttribute("vri_list", vri_list);

		modelMap.addAttribute("bo", bo);
		modelMap.addAttribute("user", user);
		modelMap.addAttribute("CHANNEL_CD", request.getParameter("CHANNEL_CD"));
		modelMap.addAttribute("DISABLED", request.getParameter("DISABLED"));

		return "channel/channelEmail";
	}

	/**
	 * 채널 EMAIL 정보 저장
	 *
	 * @param request
	 * @param response
	 * @param modelMap
	 * @return
	 * @throws Exception
	 */
	@RequestMapping("setChannelEmail.do")
	public void setChannelEmail(HttpServletRequest request, HttpServletResponse response, ModelMap modelMap, HttpSession session) throws Exception {
		Map<String, Object> map = new HashMap<String, Object>();

		UsmUserBO user = (UsmUserBO) session.getAttribute("ACCOUNT");

		//paramter
		log.info("=============================================");
		log.info("CAMPAIGNID           : " + request.getParameter("CampaignId"));
		log.info("CAMPAIGNCODE         : " + request.getParameter("CAMPAIGNCODE"));
		log.info("FLOWCHARTID          : " + request.getParameter("FLOWCHARTID"));
		log.info("CELLID               : " + request.getParameter("CELLID"));
		log.info("CHANNEL_CD           : " + request.getParameter("CHANNEL_CD"));

		log.info("EMAIL_NAME           : " + request.getParameter("EMAIL_NAME"));
		log.info("EMAIL_DESC           : " + request.getParameter("EMAIL_DESC"));
		log.info("EMAIL_EDIT_YN        : " + request.getParameter("EMAIL_EDIT_YN"));
		log.info("EMAIL_SUBJECT        : " + request.getParameter("EMAIL_SUBJECT"));
		log.info("EMAIL_CONTENT        : " + request.getParameter("EMAIL_CONTENT"));
		log.info("EMAIL_FROMNAME       : " + request.getParameter("EMAIL_FROMNAME"));
		log.info("EMAIL_FROMADDRESS    : " + request.getParameter("EMAIL_FROMADDRESS"));
		log.info("EMAIL_REPLYTO        : " + request.getParameter("EMAIL_REPLYTO"));
		log.info("EMAIL_DISP_DT        : " + request.getParameter("EMAIL_DISP_DT"));
		log.info("EMAIL_PRIORITY_RNK   : " + request.getParameter("EMAIL_PRIORITY_RNK"));
		log.info("EMAIL_DISP_TIME      : " + request.getParameter("EMAIL_DISP_TIME"));
		log.info("=============================================");

		//입력 값
		map.put("CAMPAIGNID", Common.nvl(request.getParameter("CampaignId"), ""));
		map.put("CAMPAIGNCODE", Common.nvl(request.getParameter("CAMPAIGNCODE"), ""));
		map.put("FLOWCHARTID", Common.nvl(request.getParameter("FLOWCHARTID"), ""));
		map.put("CELLID", Common.nvl(request.getParameter("CELLID"), ""));
		map.put("CHANNEL_CD", "EMAIL"); //EMAIL

		map.put("EMAIL_NAME", Common.nvl(request.getParameter("EMAIL_NAME"), ""));
		map.put("EMAIL_DESC", Common.nvl(request.getParameter("EMAIL_DESC"), ""));
		map.put("EMAIL_EDIT_YN", Common.nvl(request.getParameter("EMAIL_EDIT_YN"), ""));
		map.put("EMAIL_SUBJECT", Common.nvl(request.getParameter("EMAIL_SUBJECT"), ""));
		map.put("EMAIL_CONTENT", Common.nvl(request.getParameter("EMAIL_CONTENT"), ""));
		map.put("EMAIL_FROMNAME", Common.nvl(request.getParameter("EMAIL_FROMNAME"), ""));
		map.put("EMAIL_FROMADDRESS", Common.nvl(request.getParameter("EMAIL_FROMADDRESS"), ""));
		map.put("EMAIL_REPLYTO", Common.nvl(request.getParameter("EMAIL_REPLYTO"), ""));
		map.put("EMAIL_DISP_DT", Common.nvl(request.getParameter("EMAIL_DISP_DT"), ""));
		map.put("EMAIL_PRIORITY_RNK", Common.nvl(request.getParameter("EMAIL_PRIORITY_RNK"), ""));
		map.put("EMAIL_DISP_TIME", Common.nvl(request.getParameter("EMAIL_DISP_TIME"), ""));
		map.put("CREATE_ID", user.getId());
		map.put("UPDATE_ID", user.getId());

		//캠페인의 상태체크(START일경우에는 수정못함)
		CampaignInfoBO bo = campaignInfoService.getCampaignInfo(map);
		String CMP_STATUS = Common.nvl(bo.getCamp_status_cd(), "");

		if (!CMP_STATUS.equals("START")) {
			//EMAIL 정보 저장
			channelService.setChannelEmail(map);
		}

		//캠페인 상태 리턴
		map.put("CMP_STATUS", CMP_STATUS);

		jsonView.render(map, request, response);
	}

	@RequestMapping("/channel/_test_channelMobile.do")
	public String _test_channelMobile(HttpServletRequest request, HttpServletResponse response, ModelMap modelMap, HttpSession session) throws Exception {
		
		return "channel/_test_channelMobile";
	}
	
	/**
	 * 채널 모바일 페이지 호출
	 *
	 * @param request
	 * @param response
	 * @param modelMap
	 * @return
	 * @throws Exception
	 */
	@RequestMapping("/channel/channelMobile.do")
	public String pageChannelMobile(HttpServletRequest request, HttpServletResponse response, ModelMap modelMap, HttpSession session) throws Exception {
		//사용자 정보
		UsmUserBO user = (UsmUserBO) session.getAttribute("ACCOUNT");

		Map<String, Object> map = new HashMap<String, Object>();

		//채널 목록 조회
		map.put("codeId", "C011");
		map.put("USE_YN", "Y");
		List<UaextCodeDtlBO> channel_list = commCodeService.getCommCodeDtlList(map);

		//우선순위
		map.put("codeId", "C006");
		List<UaextCodeDtlBO> priority_rank = commCodeService.getCommCodeDtlList(map);

		//MOBILE우선순위별발송시간
		map.put("codeId", "C028");
		List<UaextCodeDtlBO> priority_rank_sendtime = commCodeService.getCommCodeDtlList(map);

		//알리미타임라인노출여부
		map.put("codeId", "C024");
		List<UaextCodeDtlBO> timeline_disp_yn = commCodeService.getCommCodeDtlList(map);

		//알리미타임라인노출여부
		map.put("codeId", "C025");
		List<UaextCodeDtlBO> push_msg_popup_indc_yn = commCodeService.getCommCodeDtlList(map);

		//모바일 알리미 구분
		map.put("codeId", "C009");
		List<UaextCodeDtlBO> mobileApp_list = commCodeService.getCommCodeDtlList(map);

		//연결페이지 구분
		map.put("codeId", "G006");
		List<UaextCodeDtlBO> mobileSendPreferCd = commCodeService.getCommCodeDtlList(map);

		//사용자 변수
		map.put("SVARI_NAME", Common.nvl(request.getParameter("SVARI_NAME"), ""));
		map.put("SKEY_COLUMN", Common.nvl(request.getParameter("SKEY_COLUMN"), ""));
		List<UaextVariableBO> vri_list = variableService.getVariableList(map);

		//paramter
		log.info("=============================================");
		log.info("CampaignId   : " + request.getParameter("CampaignId"));
		log.info("CELLID       : " + request.getParameter("CELLID"));
		log.info("CHANNEL_CD   : " + request.getParameter("CHANNEL_CD"));
		log.info("=============================================");

		//채널정보 조회
		map.put("CAMPAIGNID", Common.nvl(request.getParameter("CampaignId"), ""));
		map.put("CELLID", Common.nvl(request.getParameter("CELLID"), ""));
		map.put("CHANNEL_CD", Common.nvl(request.getParameter("CHANNEL_CD"), ""));

		ChannelBO bo = channelService.getChannelDtlInfo(map);

		modelMap.addAttribute("channel_list", channel_list);
		modelMap.addAttribute("priority_rank", priority_rank);
		modelMap.addAttribute("priority_rank_sendtime", priority_rank_sendtime);
		modelMap.addAttribute("timeline_disp_yn", timeline_disp_yn);
		modelMap.addAttribute("push_msg_popup_indc_yn", push_msg_popup_indc_yn);
		modelMap.addAttribute("mobileApp_list", mobileApp_list);
		modelMap.addAttribute("mobileSendPreferCd", mobileSendPreferCd);

		modelMap.addAttribute("vri_list", vri_list);

		modelMap.addAttribute("bo", bo);
		modelMap.addAttribute("user", user);
		modelMap.addAttribute("CHANNEL_CD", request.getParameter("CHANNEL_CD"));
		modelMap.addAttribute("DISABLED", request.getParameter("DISABLED"));

		return "channel/channelMobile";
	}

	/**
	 * KANG-20190328: add alimi data
	 * 
	 * 채널 MOBILE 정보 저장
	 *
	 * @param request
	 * @param response
	 * @param modelMap
	 * @return
	 * @throws Exception
	 */
	@RequestMapping("setChannelMobile.do")
	public void setChannelMobile(HttpServletRequest request, HttpServletResponse response, ModelMap modelMap, HttpSession session) throws Exception {
		Map<String, Object> map = new HashMap<String, Object>();

		UsmUserBO user = (UsmUserBO) session.getAttribute("ACCOUNT");

		//paramter
		log.info("=============================================");
		log.info("CAMPAIGNID              : " + request.getParameter("CampaignId"));
		log.info("CAMPAIGNCODE            : " + request.getParameter("CAMPAIGNCODE"));
		log.info("FLOWCHARTID             : " + request.getParameter("FLOWCHARTID"));
		log.info("CELLID                  : " + request.getParameter("CELLID"));
		log.info("CHANNEL_CD              : " + request.getParameter("CHANNEL_CD"));

		log.info("MOBILE_APP_KD_CD        : " + request.getParameter("MOBILE_APP_KD_CD"));
		log.info("MOBILE_DISP_TITLE       : " + request.getParameter("MOBILE_DISP_TITLE"));
		log.info("MOBILE_CONTENT          : " + request.getParameter("MOBILE_CONTENT"));
		log.info("MOBILE_ADD_TEXT         : " + request.getParameter("MOBILE_ADD_TEXT"));
		log.info("MOBILE_DISP_DT          : " + request.getParameter("MOBILE_DISP_DT"));
		log.info("MOBILE_PRIORITY_RNK     : " + request.getParameter("MOBILE_PRIORITY_RNK"));
		log.info("MOBILE_DISP_TIME        : " + request.getParameter("MOBILE_DISP_TIME"));
		log.info("TIMELINE_DISP_YN        : " + request.getParameter("TIMELINE_DISP_YN"));
		log.info("PUSH_MSG_POPUP_INDC_YN  : " + request.getParameter("PUSH_MSG_POPUP_INDC_YN"));
		log.info("THUM_IMG_URL            : " + request.getParameter("THUM_IMG_URL"));
		log.info("BNNR_IMG_URL            : " + request.getParameter("BNNR_IMG_URL"));
		log.info("useIndi                 : " + request.getParameter("useIndi"));
		log.info("MOBILE_SEND_PREFER_CD   : " + request.getParameter("MOBILE_SEND_PREFER_CD"));

		log.info("ALIMI_PARAMS            : " + request.getParameter("ALIMI_PARAMS"));
		log.info("=============================================");

		if (Flag.flag) {
			// 알리미
			String json = request.getParameter("ALIMI_PARAMS");
			JsonNode root = this.objectMapper.readTree(json);
			map.put("TALK_MSG_DISP_YN", root.path("alimiShow").asText());
			map.put("TALK_MSG_SUMMARY", root.path("alimiText").asText());
			map.put("TALK_MSG_TMPLT_NO", root.path("alimiType").asText());
			//map.put("JSON_CONTENT", json);
			map.put("TALK_BLCK_CONT", json.replace("\"", "\\\"").replace("'", "\\'"));
		}
		
		//입력 값
		map.put("CAMPAIGNID", Common.nvl(request.getParameter("CampaignId"), ""));
		map.put("CAMPAIGNCODE", Common.nvl(request.getParameter("CAMPAIGNCODE"), ""));
		map.put("FLOWCHARTID", Common.nvl(request.getParameter("FLOWCHARTID"), ""));
		map.put("CELLID", Common.nvl(request.getParameter("CELLID"), ""));
		map.put("CHANNEL_CD", "MOBILE"); //MOBILE

		map.put("MOBILE_APP_KD_CD", Common.nvl(request.getParameter("MOBILE_APP_KD_CD"), ""));
		map.put("MOBILE_DISP_TITLE", Common.nvl(request.getParameter("MOBILE_DISP_TITLE"), ""));
		map.put("MOBILE_CONTENT", Common.nvl(request.getParameter("MOBILE_CONTENT"), ""));
		map.put("MOBILE_ADD_TEXT", Common.nvl(request.getParameter("MOBILE_ADD_TEXT"), ""));
		map.put("MOBILE_DISP_DT", Common.nvl(request.getParameter("MOBILE_DISP_DT"), ""));
		map.put("MOBILE_PRIORITY_RNK", Common.nvl(request.getParameter("MOBILE_PRIORITY_RNK"), ""));
		map.put("MOBILE_DISP_TIME", Common.nvl(request.getParameter("MOBILE_DISP_TIME"), ""));
		map.put("TIMELINE_DISP_YN", Common.nvl(request.getParameter("TIMELINE_DISP_YN"), ""));
		map.put("PUSH_MSG_POPUP_INDC_YN", Common.nvl(request.getParameter("PUSH_MSG_POPUP_INDC_YN"), ""));
		map.put("THUM_IMG_URL", Common.nvl(request.getParameter("THUM_IMG_URL"), ""));
		map.put("BNNR_IMG_URL", Common.nvl(request.getParameter("BNNR_IMG_URL"), ""));

		map.put("MOBILE_LNK_PAGE_TYP", Common.nvl(request.getParameter("MOBILE_LNK_PAGE_TYP"), ""));
		map.put("MOBILE_LNK_PAGE_URL", Common.nvl(request.getParameter("MOBILE_LNK_PAGE_URL"), ""));

		map.put("useIndi", Common.nvl(request.getParameter("useIndi"), "N"));
		map.put("MOBILE_SEND_PREFER_CD", Common.nvl(request.getParameter("MOBILE_SEND_PREFER_CD"), ""));

		map.put("CREATE_ID", user.getId());
		map.put("UPDATE_ID", user.getId());

		//캠페인의 상태체크(START일경우에는 수정못함)
		CampaignInfoBO bo = this.campaignInfoService.getCampaignInfo(map);
		String CMP_STATUS = Common.nvl(bo.getCamp_status_cd(), "");

		if (!Flag.flag) {
			if (!CMP_STATUS.equals("START")) {
				//모바일 정보 저장
				this.channelService.setChannelMobile(map);
				
				// KANG-20190328: save alimi data
			}
		}
		
		if (Flag.flag) {
			this.channelService.setChannelMobileAlimi(map);
		}

		//캠페인 상태 리턴
		map.put("CMP_STATUS", CMP_STATUS);

		this.jsonView.render(map, request, response);
	}

	/**
	 * 채널 Toast배너 링크URL 조회
	 *
	 * @param request
	 * @param response
	 * @param modelMap
	 * @return
	 * @throws Exception
	 */
	@RequestMapping("channelToastLinkUrl.do")
	public void pageChannelToastLinkUrl(HttpServletRequest request, HttpServletResponse response, ModelMap modelMap, HttpSession session) throws Exception {
		Map<String, Object> map = new HashMap<String, Object>();

		//linkUrl
		map.put("codeId", "C021"); //PCID 일때의 LinkUrl
		map.put("TOAST_EVNT_TYP_CD", Common.nvl(request.getParameter("TOAST_EVNT_TYP_CD"), ""));
		String linkUrl = Common.nvl(channelService.getChannelToastLinkUrl(map), "");

		//paramter
		log.info("=============================================");
		log.info("CampaignId   : " + request.getParameter("CampaignId"));
		log.info("CELLID       : " + request.getParameter("CELLID"));
		log.info("CHANNEL_CD   : " + request.getParameter("CHANNEL_CD"));
		log.info("TOAST_EVNT_TYP_CD   : " + request.getParameter("TOAST_EVNT_TYP_CD"));
		log.info("=============================================");

		map.put("TOAST_LINK_URL", linkUrl);

		jsonView.render(map, request, response);
	}

	/**
	 *
	 *
	 * @param request
	 * @param response
	 * @param modelMap
	 * @return
	 * @throws Exception
	 */
	@RequestMapping("/delChannelInfo.do")
	public void delChannelInfo(HttpServletRequest request, HttpServletResponse response, ModelMap modelMap, HttpSession session) throws Exception {
		Map<String, Object> map = new HashMap<String, Object>();

		log.info("=============================================");
		log.info("CELLID               : " + request.getParameter("CELLID"));
		log.info("CHANNEL_CD           : " + request.getParameter("CHANNEL_CD"));
		log.info("=============================================");

		//
		map.put("CELLID", Common.nvl(request.getParameter("CELLID"), ""));
		map.put("CHANNEL_CD", Common.nvl(request.getParameter("CHANNEL_CD"), ""));

		channelService.delChannelInfo(map);

		jsonView.render(map, request, response);
	}

	/**
	 * 채널 LMS 페이지 호출
	 *
	 * @param request
	 * @param response
	 * @param modelMap
	 * @return
	 * @throws Exception
	 */
	@RequestMapping("/channel/channelLms.do")
	public String pageChannelLms(HttpServletRequest request, HttpServletResponse response, ModelMap modelMap, HttpSession session) throws Exception {
		//사용자 정보
		UsmUserBO user = (UsmUserBO) session.getAttribute("ACCOUNT");

		Map<String, Object> map = new HashMap<String, Object>();

		//채널 목록 조회
		map.put("codeId", "C011");
		map.put("USE_YN", "Y");
		List<UaextCodeDtlBO> channel_list = commCodeService.getCommCodeDtlList(map);

		//우선순위
		map.put("codeId", "C006");
		List<UaextCodeDtlBO> priority_rank = commCodeService.getCommCodeDtlList(map);

		//SMS우선순위별발송시간
		map.put("codeId", "C026");
		List<UaextCodeDtlBO> priority_rank_sendtime = commCodeService.getCommCodeDtlList(map);

		//완료시 전달번호
		map.put("codeId", "C012");
		List<UaextCodeDtlBO> comp_list = commCodeService.getCommCodeDtlList(map);

		//CALLBACK 번호
		map.put("codeId", "C023");
		List<UaextCodeDtlBO> callback_list = commCodeService.getCommCodeDtlList(map);

		//사용자 변수
		map.put("SVARI_NAME", Common.nvl(request.getParameter("SVARI_NAME"), ""));
		map.put("SKEY_COLUMN", Common.nvl(request.getParameter("SKEY_COLUMN"), ""));
		List<UaextVariableBO> vri_list = variableService.getVariableList(map);

		//paramter
		log.info("=============================================");
		log.info("CampaignId   : " + request.getParameter("CampaignId"));
		log.info("CELLID       : " + request.getParameter("CELLID"));
		log.info("CHANNEL_CD   : " + request.getParameter("CHANNEL_CD"));
		log.info("=============================================");

		//채널정보 조회
		map.put("CAMPAIGNID", Common.nvl(request.getParameter("CampaignId"), ""));
		map.put("CELLID", Common.nvl(request.getParameter("CELLID"), ""));
		map.put("CHANNEL_CD", Common.nvl(request.getParameter("CHANNEL_CD"), ""));

		ChannelBO bo = channelService.getChannelDtlInfo(map);

		modelMap.addAttribute("channel_list", channel_list);
		modelMap.addAttribute("priority_rank", priority_rank);
		modelMap.addAttribute("priority_rank_sendtime", priority_rank_sendtime);
		//modelMap.addAttribute("campScheduleTime", Common.campScheduleTime);

		modelMap.addAttribute("vri_list", vri_list);
		modelMap.addAttribute("comp_list", comp_list);
		modelMap.addAttribute("callback_list", callback_list);

		modelMap.addAttribute("bo", bo);
		modelMap.addAttribute("user", user);
		modelMap.addAttribute("CHANNEL_CD", request.getParameter("CHANNEL_CD"));
		modelMap.addAttribute("DISABLED", request.getParameter("DISABLED"));

		return "channel/channelLms";
	}

	/**
	 * 채널 SMS 정보 저장
	 *
	 * @param request
	 * @param response
	 * @param modelMap
	 * @return
	 * @throws Exception
	 */
	@RequestMapping("setChannelLms.do")
	public void setChannelLms(HttpServletRequest request, HttpServletResponse response, ModelMap modelMap, HttpSession session) throws Exception {
		Map<String, Object> map = new HashMap<String, Object>();

		UsmUserBO user = (UsmUserBO) session.getAttribute("ACCOUNT");

		//paramter
		log.info("=============================================");
		log.info("CAMPAIGNID           : " + request.getParameter("CampaignId"));
		log.info("CAMPAIGNCODE         : " + request.getParameter("CAMPAIGNCODE"));
		log.info("FLOWCHARTID          : " + request.getParameter("FLOWCHARTID"));
		log.info("CELLID               : " + request.getParameter("CELLID"));
		log.info("CHANNEL_CD           : " + request.getParameter("CHANNEL_CD"));
		log.info("LMS_TITLE            : " + request.getParameter("LMS_TITLE"));
		log.info("LMS_MSG              : " + request.getParameter("LMS_MSG"));
		log.info("LMS_PRIORITY_RNK     : " + request.getParameter("LMS_PRIORITY_RNK"));
		log.info("LMS_DISP_TIME        : " + request.getParameter("LMS_DISP_TIME"));
		log.info("LMS_LONGURL          : " + request.getParameter("LMS_LONGURL"));
		log.info("LMS_SHORTURL         : " + request.getParameter("LMS_SHORTURL"));
		log.info("LMS_DISP_DT          : " + request.getParameter("LMS_DISP_DT"));
		log.info("LMS_CALLBACK         : " + request.getParameter("LMS_CALLBACK"));
		log.info("LMS_RETURNCALL       : " + request.getParameterValues("LMS_RETURNCALL"));
		log.info("=============================================");

		String LMS_MSG = Common.nvl(request.getParameter("LMS_MSG"), "");

		//사용자 변수 목록을 조회
		map.put("SVARI_NAME", Common.nvl(request.getParameter("SVARI_NAME"), ""));
		map.put("SKEY_COLUMN", Common.nvl(request.getParameter("SKEY_COLUMN"), ""));

		List<UaextVariableBO> vri_list = variableService.getVariableList(map);

		int vai_cnt = 0;
		List<String> query_lsit0 = new ArrayList<String>(); //변수명
		List<String> query_lsit1 = new ArrayList<String>(); //참조테이블
		List<String> query_lsit2 = new ArrayList<String>(); //참조컬럼
		List<String> query_lsit3 = new ArrayList<String>(); //키컬럼
		List<String> query_lsit4 = new ArrayList<String>(); //널값일경우
		List<String> query_lsit5 = new ArrayList<String>(); //MAX BYTE

		for (int i = 0; i < vri_list.size(); i++) { //SMS 메세지에 사용자변수가 사용되었는지 체크
			UaextVariableBO bo = vri_list.get(i);

			log.info("=============================================");
			String vari_name = "{" + bo.getVari_name() + "}";
			log.info("getVari_name   : " + vari_name);

			if (LMS_MSG.indexOf(vari_name) > -1) { //변수가 존재할경우 조회 쿼리를 만든다
				log.info("변수 존재함!");

				//테스트용 데이터 조회
				String VARI_NAME = bo.getVari_name();
				String REF_TABLE = bo.getRef_table();
				String REF_COLUMN = bo.getRef_column();
				String KEY_COLUMN = bo.getKey_column();
				String IF_NULL = bo.getIf_null();
				String MAX_LENGTH = bo.getMax_byte();

				query_lsit0.add(VARI_NAME);
				query_lsit1.add(REF_TABLE);
				query_lsit2.add(REF_COLUMN);
				query_lsit3.add(KEY_COLUMN);
				query_lsit4.add(IF_NULL);
				query_lsit5.add(MAX_LENGTH);

				vai_cnt++; //카운트 +1

				log.info("* VARI_NAME : " + VARI_NAME + " * REF_TABLE : " + REF_TABLE + " * REF_COLUMN : " + REF_COLUMN
						+ " * KEY_COLUMN : " + KEY_COLUMN + " * IF_NULL : " + IF_NULL + " * MAX_LENGTH : " + MAX_LENGTH);
			} else {
				log.info("변수 미존재..");
			}
			log.info("=============================================");
		}

		// 		조회쿼리를 생성하여 db에 저장한다(ex)
		//		SELECT T.MEM_NO, T1.NAME || '님 반갑습니다 ' || T2.RANK || '등급이 되셨습니다'
		//		  FROM [TARGETTABLE] T
		//		,(SELECT NAME FROM TABLE1) T1
		//		,(SELECT CODE FROM TABLE2) T2
		//		WHERE T0.MEM_NO = T1.KEY1(+)
		//		  AND T0.MEM_NO = T2.KEY2(+)

		String LMS_MSG_QUERY = "";
		String LMS_MSG_QUERY1 = ""; //SELECT T.MEM_NO,
		String LMS_MSG_QUERY2 = ""; //[TARGETTABLE]
		String LMS_MSG_QUERY3 = ""; //FROM
		String LMS_MSG_QUERY4 = ""; //WHERE

		for (int i = 0; i < vai_cnt; i++) { //존재한 변수만큼 조회 쿼리를 만든다

			if (i == 0) { //최초
				LMS_MSG_QUERY1 += "SELECT T.MEM_NO, '" + LMS_MSG + "'";
				LMS_MSG_QUERY1 = LMS_MSG_QUERY1.replaceAll("\\{" + query_lsit0.get(i) + "}", "' || SUBSTRB(NVL(T" + i + "."
						+ query_lsit2.get(i) + ", '" + query_lsit4.get(i) + "'), 0," + query_lsit5.get(i) + ") || '");
				LMS_MSG_QUERY2 += " FROM [TARGETTABLE] T";
				LMS_MSG_QUERY3 += " , (SELECT * FROM " + query_lsit1.get(i) + ") T" + i;
				LMS_MSG_QUERY4 += " WHERE T.MEM_NO = T" + i + "." + query_lsit3.get(i) + "(+)";
			} else {
				LMS_MSG_QUERY1 = LMS_MSG_QUERY1.replaceAll("\\{" + query_lsit0.get(i) + "}", "' || SUBSTRB(NVL(T" + i + "."
						+ query_lsit2.get(i) + ", '" + query_lsit4.get(i) + "'), 0," + query_lsit5.get(i) + ") || '");
				LMS_MSG_QUERY3 += " , (SELECT * FROM " + query_lsit1.get(i) + ") T" + i;
				LMS_MSG_QUERY4 += " AND T.MEM_NO = T" + i + "." + query_lsit3.get(i) + "(+)";
			}
		}

		LMS_MSG_QUERY = LMS_MSG_QUERY1 + LMS_MSG_QUERY2 + LMS_MSG_QUERY3 + LMS_MSG_QUERY4;

		log.info("=============================================");
		log.info("LMS_MSG_QUERY ::: " + LMS_MSG_QUERY);
		log.info("=============================================");

		//입력 값
		map.put("CAMPAIGNID", Common.nvl(request.getParameter("CampaignId"), ""));
		map.put("CAMPAIGNCODE", Common.nvl(request.getParameter("CAMPAIGNCODE"), ""));
		map.put("FLOWCHARTID", Common.nvl(request.getParameter("FLOWCHARTID"), ""));
		map.put("CELLID", Common.nvl(request.getParameter("CELLID"), ""));
		map.put("CHANNEL_CD", "LMS"); //SMS
		map.put("LMS_TITLE", Common.nvl(request.getParameter("LMS_TITLE"), ""));
		map.put("LMS_MSG", Common.nvl(request.getParameter("LMS_MSG"), ""));
		map.put("LMS_MSG_QUERY", Common.nvl(LMS_MSG_QUERY, ""));
		map.put("LMS_PRIORITY_RNK", Common.nvl(request.getParameter("LMS_PRIORITY_RNK"), ""));

		map.put("LMS_DISP_TIME", Common.nvl(request.getParameter("LMS_DISP_TIME"), ""));

		map.put("LMS_LONGURL", Common.nvl(request.getParameter("LMS_LONGURL"), ""));
		map.put("LMS_SHORTURL", Common.nvl(request.getParameter("LMS_SHORTURL"), ""));
		map.put("LMS_DISP_DT", Common.nvl(request.getParameter("LMS_DISP_DT"), ""));
		map.put("LMS_CALLBACK", Common.nvl(request.getParameter("LMS_CALLBACK"), ""));
		String LMS_RETURNCALLS[] = request.getParameterValues("LMS_RETURNCALL");
		String LMS_RETURNCALL = "";
		for (int i = 0; i < LMS_RETURNCALLS.length; i++) {
			if (i == 0) {
				LMS_RETURNCALL = LMS_RETURNCALLS[i];
			} else {
				LMS_RETURNCALL += ";" + LMS_RETURNCALLS[i];
			}
		}
		map.put("LMS_RETURNCALL", LMS_RETURNCALL);
		map.put("CREATE_ID", user.getId());
		map.put("UPDATE_ID", user.getId());

		//캠페인의 상태체크(START일경우에는 수정못함)
		CampaignInfoBO bo = campaignInfoService.getCampaignInfo(map);
		String CMP_STATUS = Common.nvl(bo.getCamp_status_cd(), "");

		if (!CMP_STATUS.equals("START")) {
			//SMS 정보 저장
			channelService.setChannelLms(map);
		}

		//캠페인 상태 리턴
		map.put("CMP_STATUS", CMP_STATUS);

		jsonView.render(map, request, response);
	}

	/**
	 * 채널 LMS ShortURL가져오기
	 *
	 * @param request
	 * @param response
	 * @param modelMap
	 * @return
	 * @throws Exception
	 */
	@RequestMapping("/channelLmsShortUrl.do")
	public void channelLmsShortUrl(HttpServletRequest request, HttpServletResponse response, ModelMap modelMap) throws Exception {
		Map<String, Object> map = new HashMap<String, Object>();

		//paramter
		log.info("=============================================");
		log.info("LMS_LONGURL   : " + request.getParameter("LMS_LONGURL"));

		String LMS_LONGURL = "http://bizapi.11st.co.kr/jsp/message/get_callback_url.jsp?domain=11st.kr&url="
				+ Common.nvl(request.getParameter("LMS_LONGURL"), "");

		log.info("LMS_LONGURL2   : " + LMS_LONGURL);
		log.info("=============================================");

		//url 가져오기
		URL url = null;
		String line = "";
		BufferedReader input = null;
		String ShortUrl = "";

		try {
			url = new URL(LMS_LONGURL);
			input = new BufferedReader(new InputStreamReader(url.openStream()));
			while ((line = input.readLine()) != null) {
				ShortUrl += line;
			}

			log.info("=============================================");
			log.info("SHORT_URL   : " + ShortUrl);
			log.info("=============================================");
		} catch (MalformedURLException mue) {
			log.info("잘못되 URL입니다. 사용법 : java URLConn http://hostname/path]");
		} catch (IOException ioe) {
			log.info("IOException " + ioe);
			ioe.printStackTrace();
		}

		map.put("SHORT_URL", ShortUrl);

		jsonView.render(map, request, response);
	}

	/**
	 * 채널 SMS 미리보기
	 *
	 * @param request
	 * @param response
	 * @param modelMap
	 * @return
	 * @throws Exception
	 */
	@RequestMapping("/channelLmsPreview.do")
	public void channelLmsPreview(HttpServletRequest request, HttpServletResponse response, ModelMap modelMap) throws Exception {
		Map<String, Object> map = new HashMap<String, Object>();

		//paramter
		log.info("=============================================");
		log.info("LMS_INPUT_MSG   : " + request.getParameter("LMS_INPUT_MSG"));
		log.info("=============================================");

		String LMS_MSG = Common.nvl(request.getParameter("LMS_INPUT_MSG"), "");

		//사용자 변수 목록을 조회
		map.put("SVARI_NAME", Common.nvl(request.getParameter("SVARI_NAME"), ""));
		map.put("SKEY_COLUMN", Common.nvl(request.getParameter("SKEY_COLUMN"), ""));

		List<UaextVariableBO> vri_list = variableService.getVariableList(map);

		for (int i = 0; i < vri_list.size(); i++) { //Toast 메세지에 사용자변수가 사용되었는지 체크
			UaextVariableBO bo = vri_list.get(i);

			log.info("=============================================");
			String vari_name = "{" + bo.getVari_name() + "}";
			log.info("getVari_name   : " + vari_name);

			if (LMS_MSG.indexOf(vari_name) > -1) { //변수가 존재할경우
				log.info("변수 존재함!");

				//테스트용 데이터 조회
				map.put("REF_TABLE", bo.getRef_table());
				map.put("REF_COLUMN", bo.getRef_column());
				map.put("KEY_COLUMN", bo.getKey_column());
				map.put("MAX_BYTE", bo.getMax_byte());

				String preval = variableService.getVariablePreVal(map);
				log.info("조회된 변수값   : " + preval);

				//변수값 변경하기
				LMS_MSG = LMS_MSG.replaceAll("\\" + vari_name, preval);
				log.info("변경된 값   : " + LMS_MSG);

			} else {
				log.info("변수 미존재..");
			}
			log.info("=============================================");
		}

		map.put("LMS_INPUT_MSG", LMS_MSG);

		jsonView.render(map, request, response);
	}
}
