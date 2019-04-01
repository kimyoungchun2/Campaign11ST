package com.skplanet.sascm.util;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Map;

import com.google.common.collect.Lists;
import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.google.gson.JsonObject;
import com.google.gson.reflect.TypeToken;

import skt.tmall.talk.dto.PushTalkParameter;
import skt.tmall.talk.dto.type.AppKdCdType;
import skt.tmall.talk.dto.type.Block;
import skt.tmall.talk.dto.type.BlockBoldText;
import skt.tmall.talk.dto.type.BlockBtnView;
import skt.tmall.talk.dto.type.BlockImg500;
import skt.tmall.talk.dto.type.BlockLinkUrl;
import skt.tmall.talk.dto.type.BlockTopCap;
import skt.tmall.talk.service.PushTalkSendService;

public class Type1JsonTestMain {

	private static boolean flag = true;
	
	public static void main(String[] args) throws Exception {
		if (flag) test01();
	}
	
	@SuppressWarnings("unchecked")
	private static void test01() {
		Gson gson = new Gson();
		String jsonParams = null;
		Map<String, Object> mapParams = null;
		List<Block> composites = null;
		
		if (flag) {
			jsonParams = "{\"alimiShow\":\"Y\",\"alimiText\":\"a\",\"alimiType\":\"001\",\"title1\":\"b\",\"advText\":\"광고\",\"title2\":\"c\",\"title3\":\"d\",\"arrImg\":[{\"imgUrl\":\"e\"},{\"imgUrl\":\"http://...\"}],\"ftrText\":\"f\",\"ftrMblUrl\":\"g\",\"ftrWebUrl\":\"h\"}";
			jsonParams = "{\"alimiShow\":\"Y\",\"alimiText\":\"a\",\"alimiType\":\"001\",\"title1\":\"패션워크\",\"advText\":\"광고\",\"title2\":\"반값 타임딜 하루 44번 오픈\",\"title3\":\"놓치지마세요!\",\"arrImg\":[{\"imgUrl\":\"http://i.011st.com/ui_img/11talk/img_500_500_sample2.png\"},{\"imgUrl\":\"http://i.011st.com/ui_img/11talk/img_500_500_sample2.png\"}],\"ftrText\":\"상세보기(44)\",\"ftrMblUrl\":\"http://m.11st.co.kr/MW/MyPage/V1/benefitCouponDownList.tmall\",\"ftrWebUrl\":\"http://11st.co.kr\"}";
		}
		
		if (flag) {
			mapParams = gson.fromJson(jsonParams, new TypeToken<Map<String, Object>>(){}.getType());
			if (flag) {
				System.out.println("----- mapParams -----");
				System.out.println("alimiText: " + mapParams.get("alimiText"));
				System.out.println("title1: " + mapParams.get("title1"));
				System.out.println("arrImg: " + mapParams.get("arrImg"));
				for (Map<String, Object> map : (List<Map<String, Object>>) mapParams.get("arrImg")) {
					System.out.println(">>>>> " + map);
				}
			}
		}
		
		if (flag) {
			List<BlockImg500.Value> list = new ArrayList<>();
			for (Map<String, Object> map : (List<Map<String, Object>>) mapParams.get("arrImg")) {
				list.add(new BlockImg500.Value((String) map.get("imgUrl")));
			}
			composites = Lists.newArrayList(
					new BlockTopCap(new BlockTopCap.Value((String) mapParams.get("title1"), (String) mapParams.get("advText")))
					, new BlockBoldText(new BlockBoldText.Value((String) mapParams.get("title2"), (String) mapParams.get("title3")))
					, new BlockImg500(list)
					, new BlockBtnView(new BlockBtnView.Value((String) mapParams.get("ftrText"), new BlockLinkUrl((String) mapParams.get("ftrMblUrl"), (String) mapParams.get("ftrWebUrl"))))
			);
			if (flag) {
				System.out.println("----- composites -----");
				System.out.println(">>>>> " + composites);
				System.out.println(">>>>> " + new GsonBuilder().setPrettyPrinting().create().toJson(composites));
			}
		}
		
		if (flag) {
			// environment
			System.setProperty("server.type", "real");
			
			// 알림톡 템플릿에 등록한 메시지 타입코드 or "002"
			String talkMsgTempNo = "001";
			
			// memberNo: 김영천(18468196) 강석(12774111) 김창범(20750578,42751905,10000276)
			Long memberNo;
			memberNo = 18468196L;  // 김영천(18468196)
			//memberNo = 12774111L;  // 강석 (12774111)
			//memberNo = 20750578L;  // 김창범(20750578) 개발 김창범(42751905,10000276)
			
			// 발송대상 앱코드
			AppKdCdType appKdCd = AppKdCdType.ELEVENSTAPP;
			
			// 푸시메시지
			int seq = 1004;
			JsonObject obj = new JsonObject();
			obj.addProperty("IOS_MSG", "아이폰 메시지~개인화테스트입니다~"+seq+"번째(포맷유지)");
			obj.addProperty("AND_TOP_MSG", "안드로이드 메시지~~개인화테스트입니다~"+seq+"번째(포맷변경)");
			obj.addProperty("AND_BTM_MSG", "안드로이드 메시지~~개인화테스트입니다~"+seq+"번째(포맷변경)");
			if (flag) {
				System.out.println(">>>>> " + obj.toString());
			}
			
			// Url
			String detailUrl = "http://m.11st.co.kr/MW/TData/dataFree.tmall";
			String bannerUrl = "http://m.11st.co.kr";
			String etcSasData = "{ \"campaigncode\":\"CAMP00000\", \"treatmentcode\":\"TR00000\" }";
			Map<String,String> mapEtcSasData = gson.fromJson(etcSasData, new TypeToken<Map<String, Object>>(){}.getType());
			String summary = "주문 알림톡입니다.("+seq+")";  // 알림톡방 리스트에 노출 할 메시지
			
			/////////////////////////////////////////
			// 알림톡 인자 세팅
			PushTalkParameter pushTalkParam = new PushTalkParameter(talkMsgTempNo, memberNo);
			pushTalkParam.setAppKdCd(appKdCd);             // 발송대상 앱코드
			//pushTalkParam.setMsgGrpNo(1235L);              // 메시지 식별 그룹번호. 없을경우 생략가능
			pushTalkParam.setPushIosMessage(obj.toString());     // JSON (?)
			pushTalkParam.setPushTopMessage(obj.toString());     // JSON (?)
			pushTalkParam.setPushBottomMessage(obj.toString());  // JSON (?)
			//pushTalkParam.setPushIosMessage(obj.get("IOS_MSG").getAsString());         // IOS message
			//pushTalkParam.setPushTopMessage(obj.get("AND_TOP_MSG").getAsString());     // Android Top message
			//pushTalkParam.setPushBottomMessage(obj.get("AND_BTM_MSG").getAsString());  // Android Bottom message
			pushTalkParam.setTalkDispYn("Y");              // 고정 처리 (Y) 알림-혜택톡방 동시 사용함
			pushTalkParam.setDetailUrl(detailUrl);         // 일반푸시 사용시- 클릭URL
			pushTalkParam.setBannerUrl(bannerUrl);         // 푸시배너이미지. 없을경우 생략가능
			pushTalkParam.setEtcData(mapEtcSasData);       // 기타 데이타 SAS에서 사용
			pushTalkParam.setTalkSummaryMessage(summary);  // 알림톡방 리스트에 노출 할 메시지
			pushTalkParam.setTalkMessage(composites);      // data from DB Table CM_CAMPAIGN_CHANNEL_JS
			pushTalkParam.setSendAllwBgnDt(new Date());    // 예약발송시 설정.
			// SMS 셋팅 http://wiki.11stcorp.com/pages/viewpage.action?pageId=214088691
			//pushTalkParam.setSmsMsg("SMS 스펙에 해당하는 데이터 작성");
			// 테스트 데이터 셋팅, 운영모드 일 경우 Remarking
			if (flag) {
				System.out.println(">>>>> " + pushTalkParam);
			}
			
			try {
				//알림톡 전송
				int ret = -1;
				if (flag) ret = PushTalkSendService.INSTANCE.remoteSyncPush(Lists.newArrayList(pushTalkParam));
				System.out.println("ret = " + ret);
			} catch (Exception e) {
				e.printStackTrace();
			}
		}
	}
}
