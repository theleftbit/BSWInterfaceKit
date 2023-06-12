/*!
 * This source file is part of the Swift.org open source project
 * 
 * Copyright (c) 2021 Apple Inc. and the Swift project authors
 * Licensed under Apache License v2.0 with Runtime Library Exception
 * 
 * See https://swift.org/LICENSE.txt for license information
 * See https://swift.org/CONTRIBUTORS.txt for Swift project authors
 */
(window["webpackJsonp"]=window["webpackJsonp"]||[]).push([["tutorials-overview"],{"032c":function(t,e,n){"use strict";n("9b79")},"0b61":function(t,e,n){},"13d5":function(t,e,n){},"17d2":function(t,e,n){},"202a":function(t,e,n){"use strict";n("5899")},"277b":function(t,e,n){"use strict";n("60ca")},"29e3":function(t,e,n){"use strict";n("0b61")},3233:function(t,e,n){"use strict";n("8d8f")},4230:function(t,e,n){"use strict";n("52f5")},"441c":function(t,e,n){},"52f5":function(t,e,n){},5899:function(t,e,n){},"60ca":function(t,e,n){},"653a":function(t,e,n){"use strict";var i=function(){var t=this,e=t.$createElement,n=t._self._c||e;return n("router-link",{staticClass:"nav-title-content",attrs:{to:t.to}},[n("span",{staticClass:"title"},[t._t("default")],2),n("span",{staticClass:"subhead"},[t._v(" "),t._t("subhead")],2)])},s=[],a={name:"NavTitleContainer",props:{to:{type:[String,Object],required:!0}}},o=a,r=(n("f1e6"),n("2877")),c=Object(r["a"])(o,i,s,!1,null,"854b4dd6",null);e["a"]=c.exports},6899:function(t,e,n){"use strict";n("441c")},"6fb0":function(t,e,n){"use strict";n("eec8")},"7c60":function(t,e,n){},"8d8f":function(t,e,n){},"8f86":function(t,e,n){},9359:function(t,e,n){"use strict";n("9e08")},9792:function(t,e,n){"use strict";n("c8c8")},"9aea":function(t,e,n){},"9b79":function(t,e,n){},"9e08":function(t,e,n){},a0d4:function(t,e,n){},a975:function(t,e,n){"use strict";n("7c60")},aebc:function(t,e,n){"use strict";n("c0c9")},b9bf:function(t,e,n){"use strict";n("13d5")},bc97:function(t,e,n){"use strict";n("9aea")},c0c9:function(t,e,n){},c8c8:function(t,e,n){},ca4e:function(t,e,n){"use strict";n("17d2")},de60:function(t,e,n){"use strict";var i=function(){var t=this,e=t.$createElement,n=t._self._c||e;return n("SVGIcon",{staticClass:"download-icon",attrs:{viewBox:"0 0 14 14",themeId:"download"}},[n("path",{attrs:{d:"M7 0.5c3.59 0 6.5 2.91 6.5 6.5s-2.91 6.5-6.5 6.5c-3.59 0-6.5-2.91-6.5-6.5s2.91-6.5 6.5-6.5zM7 1.5c-3.038 0-5.5 2.462-5.5 5.5s2.462 5.5 5.5 5.5c3.038 0 5.5-2.462 5.5-5.5s-2.462-5.5-5.5-5.5z"}}),n("path",{attrs:{d:"M7.51 2.964l-0.001 5.431 1.308-2.041 0.842 0.539-2.664 4.162-2.633-4.164 0.845-0.534 1.303 2.059 0.001-5.452z"}})])},s=[],a=n("be08"),o={name:"DownloadIcon",components:{SVGIcon:a["a"]}},r=o,c=n("2877"),l=Object(c["a"])(r,i,s,!1,null,null,null);e["a"]=l.exports},dfc1:function(t,e,n){},ed64:function(t,e,n){"use strict";n("dfc1")},eec8:function(t,e,n){},f025:function(t,e,n){"use strict";n.r(e);var i,s,a=function(){var t=this,e=t.$createElement,n=t._self._c||e;return t.topicData?n("Overview",t._b({key:t.topicKey},"Overview",t.overviewProps,!1)):t._e()},o=[],r=n("25a9"),c=n("0caf"),l=function(){var t=this,e=t.$createElement,n=t._self._c||e;return n("div",{staticClass:"tutorials-overview"},[t.isTargetIDE?t._e():n("Nav",{staticClass:"theme-dark",attrs:{sections:t.otherSections}},[t._v(" "+t._s(t.title)+" ")]),n("main",{staticClass:"main",attrs:{id:"main",role:"main",tabindex:"0"}},[n("div",{staticClass:"radial-gradient"},[t._t("above-hero"),t.heroSection?n("Hero",{attrs:{action:t.heroSection.action,content:t.heroSection.content,estimatedTime:t.metadata.estimatedTime,image:t.heroSection.image,title:t.heroSection.title}}):t._e()],2),t.otherSections.length>0?n("LearningPath",{attrs:{sections:t.otherSections}}):t._e()],1)],1)},u=[],m={state:{activeTutorialLink:null,activeVolume:null,references:{}},reset(){this.state.activeTutorialLink=null,this.state.activeVolume=null,this.state.references={}},setActiveSidebarLink(t){this.state.activeTutorialLink=t},setActiveVolume(t){this.state.activeVolume=t},setReferences(t){this.state.references=t}},d=function(){var t=this,e=t.$createElement,n=t._self._c||e;return n("NavBase",[n("NavTitleContainer",{attrs:{to:t.buildUrl(t.$route.path,t.$route.query)}},[n("template",{slot:"default"},[t._t("default")],2),n("template",{slot:"subhead"},[t._v(t._s(t.$tc("tutorials.title",2)))])],2),n("template",{slot:"menu-items"},[n("NavMenuItemBase",{staticClass:"in-page-navigation"},[n("TutorialsNavigation",{attrs:{sections:t.sections}})],1),t._t("menu-items")],2)],2)},p=[],h=n("cbcf"),v=function(){var t=this,e=t.$createElement,n=t._self._c||e;return n("nav",{staticClass:"tutorials-navigation"},[n("TutorialsNavigationList",t._l(t.sections,(function(e,i){return n("li",{key:e.name+"_"+i,class:t.sectionClasses(e)},[t.isVolume(e)?n(t.componentForVolume(e),t._b({tag:"component",on:{"select-menu":t.onSelectMenu,"deselect-menu":t.onDeselectMenu}},"component",t.propsForVolume(e),!1),t._l(e.chapters,(function(e){return n("li",{key:e.name},[n("TutorialsNavigationLink",[t._v(" "+t._s(e.name)+" ")])],1)})),0):t.isResources(e)?n("TutorialsNavigationLink",[t._v(" "+t._s(t.$t("sections.resources"))+" ")]):t._e()],1)})),0)],1)},f=[],b=function(){var t=this,e=t.$createElement,n=t._self._c||e;return n("router-link",{staticClass:"tutorials-navigation-link",class:{active:t.active},attrs:{to:t.fragment},nativeOn:{click:function(e){return t.handleFocusAndScroll(t.fragment.hash)}}},[t._t("default")],2)},_=[],g=n("002d"),C=n("8a61"),y={name:"TutorialsNavigationLink",mixins:[C["a"]],inject:{store:{default:()=>({state:{}})}},data(){return{state:this.store.state}},computed:{active:({state:{activeTutorialLink:t},text:e})=>e===t,fragment:({text:t,$route:e})=>({hash:Object(g["a"])(t),query:e.query}),text:({$slots:{default:[{text:t}]}})=>t.trim()}},T=y,S=(n("6fb0"),n("2877")),V=Object(S["a"])(T,b,_,!1,null,"e9f9b59c",null),k=V.exports,I=function(){var t=this,e=t.$createElement,n=t._self._c||e;return n("ol",{staticClass:"tutorials-navigation-list",attrs:{role:"list"}},[t._t("default")],2)},x=[],N={name:"TutorialsNavigationList"},O=N,$=(n("202a"),Object(S["a"])(O,I,x,!1,null,"6f2800d1",null)),j=$.exports,w=function(){var t=this,e=t.$createElement,n=t._self._c||e;return n("div",{staticClass:"tutorials-navigation-menu",class:{collapsed:t.collapsed}},[n("button",{staticClass:"toggle",attrs:{"aria-expanded":t.collapsed?"false":"true",type:"button"},on:{click:function(e){return e.stopPropagation(),t.onClick.apply(null,arguments)}}},[n("span",{staticClass:"text"},[t._v(t._s(t.title))]),n("InlineCloseIcon",{staticClass:"toggle-icon icon-inline"})],1),n("transition-expand",[t.collapsed?t._e():n("div",{staticClass:"tutorials-navigation-menu-content"},[n("TutorialsNavigationList",{attrs:{"aria-label":t.$t("tutorials.nav.chapters")}},[t._t("default")],2)],1)])],1)},A=[],q=function(){var t=this,e=t.$createElement,n=t._self._c||e;return n("SVGIcon",{staticClass:"inline-close-icon",attrs:{viewBox:"0 0 14 14",themeId:"inline-close"}},[n("path",{attrs:{d:"M11.91 1l1.090 1.090-4.917 4.915 4.906 4.905-1.090 1.090-4.906-4.905-4.892 4.894-1.090-1.090 4.892-4.894-4.903-4.904 1.090-1.090 4.903 4.904z"}})])},E=[],L=n("be08"),M={name:"InlineCloseIcon",components:{SVGIcon:L["a"]}},D=M,F=Object(S["a"])(D,q,E,!1,null,null,null),R=F.exports,B={name:"TransitionExpand",functional:!0,render(t,e){const n={props:{name:"expand"},on:{afterEnter(t){t.style.height="auto"},enter(t){const{width:e}=getComputedStyle(t);t.style.width=e,t.style.position="absolute",t.style.visibility="hidden",t.style.height="auto";const{height:n}=getComputedStyle(t);t.style.width=null,t.style.position=null,t.style.visibility=null,t.style.height=0,getComputedStyle(t).height,requestAnimationFrame(()=>{t.style.height=n})},leave(t){const{height:e}=getComputedStyle(t);t.style.height=e,getComputedStyle(t).height,requestAnimationFrame(()=>{t.style.height=0})}}};return t("transition",n,e.children)}},G=B,z=(n("032c"),Object(S["a"])(G,i,s,!1,null,null,null)),P=z.exports,H={name:"TutorialsNavigationMenu",components:{InlineCloseIcon:R,TransitionExpand:P,TutorialsNavigationList:j},props:{collapsed:{type:Boolean,default:!0},title:{type:String,required:!0}},methods:{onClick(){this.collapsed?this.$emit("select-menu",this.title):this.$emit("deselect-menu")}}},K=H,U=(n("277b"),Object(S["a"])(K,w,A,!1,null,"489416f8",null)),Z=U.exports;const J={resources:"resources",volume:"volume"};var Q={name:"TutorialsNavigation",components:{TutorialsNavigationLink:k,TutorialsNavigationList:j,TutorialsNavigationMenu:Z},constants:{SectionKind:J},inject:{store:{default:()=>({setActiveVolume(){}})}},data(){return{state:this.store.state}},props:{sections:{type:Array,required:!0}},computed:{activeVolume:({state:t})=>t.activeVolume},methods:{sectionClasses(t){return{volume:this.isVolume(t),"volume--named":this.isNamedVolume(t),resource:this.isResources(t)}},componentForVolume:({name:t})=>t?Z:j,isResources:({kind:t})=>t===J.resources,isVolume:({kind:t})=>t===J.volume,activateFirstNamedVolume(){const{isNamedVolume:t,sections:e}=this,n=e.find(t);n&&this.store.setActiveVolume(n.name)},isNamedVolume(t){return this.isVolume(t)&&t.name},onDeselectMenu(){this.store.setActiveVolume(null)},onSelectMenu(t){this.store.setActiveVolume(t)},propsForVolume({name:t}){const{activeVolume:e}=this;return t?{collapsed:t!==e,title:t}:{"aria-label":"Chapters"}}},created(){this.activateFirstNamedVolume()}},W=Q,X=(n("a975"),Object(S["a"])(W,v,f,!1,null,"79093ed6",null)),Y=X.exports,tt=n("653a"),et=n("d26a"),nt=n("863d");const it={resources:"resources",volume:"volume"};var st={name:"Nav",constants:{SectionKind:it},components:{NavMenuItemBase:nt["a"],NavTitleContainer:tt["a"],TutorialsNavigation:Y,NavBase:h["a"]},props:{sections:{type:Array,require:!0}},methods:{buildUrl:et["b"]}},at=st,ot=(n("9359"),Object(S["a"])(at,d,p,!1,null,"b806ee20",null)),rt=ot.exports,ct=n("bf08"),lt=function(){var t=this,e=t.$createElement,n=t._self._c||e;return n("section",{staticClass:"hero"},[n("div",{staticClass:"copy-container"},[n("h1",{staticClass:"title"},[t._v(t._s(t.title))]),t.content?n("ContentNode",{attrs:{content:t.content}}):t._e(),t.estimatedTime?n("p",{staticClass:"meta"},[n("TimerIcon"),n("span",{staticClass:"meta-content"},[n("strong",{staticClass:"time"},[t._v(t._s(t.estimatedTime))]),n("span",[t._v(" "+t._s(t.$t("tutorials.estimated-time")))])])],1):t._e(),t.action?n("CallToActionButton",{attrs:{action:t.action,"aria-label":t.$t("tutorials.overriding-title",{newTitle:t.action.overridingTitle,title:t.title}),isDark:""}}):t._e()],1),t.image?n("Asset",{attrs:{identifier:t.image}}):t._e()],1)},ut=[],mt=n("80e4"),dt=n("c081"),pt=n("5677"),ht=function(){var t=this,e=t.$createElement,n=t._self._c||e;return n("SVGIcon",{staticClass:"timer-icon",attrs:{viewBox:"0 0 14 14",themeId:"timer"}},[n("path",{attrs:{d:"M7 0.5c3.59 0 6.5 2.91 6.5 6.5s-2.91 6.5-6.5 6.5c-3.59 0-6.5-2.91-6.5-6.5v0c0-3.59 2.91-6.5 6.5-6.5v0zM7 2c-2.761 0-5 2.239-5 5s2.239 5 5 5c2.761 0 5-2.239 5-5v0c0-2.761-2.239-5-5-5v0z"}}),n("path",{attrs:{d:"M6.51 3.51h1.5v3.5h-1.5v-3.5z"}}),n("path",{attrs:{d:"M6.51 7.010h4v1.5h-4v-1.5z"}})])},vt=[],ft={name:"TimerIcon",components:{SVGIcon:L["a"]}},bt=ft,_t=Object(S["a"])(bt,ht,vt,!1,null,null,null),gt=_t.exports,Ct={name:"Hero",components:{Asset:mt["a"],CallToActionButton:dt["a"],ContentNode:pt["default"],TimerIcon:gt},props:{action:{type:Object,required:!1},content:{type:Array,required:!1},estimatedTime:{type:String,required:!1},image:{type:String,required:!1},title:{type:String,required:!0}}},yt=Ct,Tt=(n("29e3"),Object(S["a"])(yt,lt,ut,!1,null,"383dab71",null)),St=Tt.exports,Vt=function(){var t=this,e=t.$createElement,n=t._self._c||e;return n("div",{staticClass:"learning-path",class:t.classes},[n("div",{staticClass:"main-container"},[t.isTargetIDE?t._e():n("div",{staticClass:"secondary-content-container"},[n("TutorialsNavigation",{attrs:{sections:t.sections,"aria-label":t.$t("sections.on-this-page")}})],1),n("div",{staticClass:"primary-content-container"},[n("div",{staticClass:"content-sections-container"},[t._l(t.volumes,(function(e,i){return n("Volume",t._b({key:"volume_"+i,staticClass:"content-section"},"Volume",t.propsFor(e),!1))})),t._l(t.otherSections,(function(e,i){return n(t.componentFor(e),t._b({key:"resource_"+i,tag:"component",staticClass:"content-section"},"component",t.propsFor(e),!1))}))],2)])])])},kt=[],It=function(){var t=this,e=t.$createElement,n=t._self._c||e;return n("section",{staticClass:"resources",attrs:{id:"resources",tabindex:"-1"}},[n("VolumeName",{attrs:{name:t.$t("sections.resources"),content:t.content}}),n("TileGroup",{attrs:{tiles:t.tiles}})],1)},xt=[],Nt=n("72e7");const Ot={topOneThird:"-30% 0% -70% 0%",center:"-50% 0% -50% 0%"};var $t={mixins:[Nt["a"]],computed:{intersectionRoot(){return null},intersectionRootMargin(){return Ot.center}},methods:{onIntersect(t){if(!t.isIntersecting)return;const e=this.onIntersectViewport;e?e():console.warn("onIntersectViewportCenter not implemented")}}},jt=function(){var t=this,e=t.$createElement,n=t._self._c||e;return n("div",{staticClass:"volume-name"},[t.image?n("Asset",{staticClass:"image",attrs:{identifier:t.image,"aria-hidden":"true"}}):t._e(),n("h2",{staticClass:"name"},[t._v(" "+t._s(t.name)+" ")]),t.content?n("ContentNode",{attrs:{content:t.content}}):t._e()],1)},wt=[],At={name:"VolumeName",components:{ContentNode:pt["default"],Asset:mt["a"]},props:{image:{type:String,required:!1},content:{type:Array,required:!1},name:{type:String,required:!1}}},qt=At,Et=(n("ca4e"),Object(S["a"])(qt,jt,wt,!1,null,"569db166",null)),Lt=Et.exports,Mt=function(){var t=this,e=t.$createElement,n=t._self._c||e;return n("div",{staticClass:"tile-group",class:t.countClass},t._l(t.tiles,(function(e){return n("Tile",t._b({key:e.title},"Tile",t.propsFor(e),!1))})),1)},Dt=[],Ft=function(){var t=this,e=t.$createElement,n=t._self._c||e;return n("div",{staticClass:"tile"},[t.identifier?n("div",{staticClass:"icon"},[n(t.iconComponent,{tag:"component"})],1):t._e(),n("div",{staticClass:"title"},[t._v(t._s(t.title))]),n("ContentNode",{attrs:{content:t.content}}),t.action?n("DestinationDataProvider",{attrs:{destination:t.action},scopedSlots:t._u([{key:"default",fn:function(e){var i=e.url,s=e.title;return n("Reference",{staticClass:"link",attrs:{url:i}},[t._v(" "+t._s(s)+" "),n("InlineChevronRightIcon",{staticClass:"link-icon icon-inline"})],1)}}],null,!1,3874201962)}):t._e()],1)},Rt=[],Bt=n("3b96"),Gt=function(){var t=this,e=t.$createElement,n=t._self._c||e;return n("SVGIcon",{staticClass:"document-icon",attrs:{viewBox:"0 0 14 14",themeId:"document"}},[n("path",{attrs:{d:"M11.2,5.3,8,2l-.1-.1H2.8V12.1h8.5V6.3l-.1-1ZM8,3.2l2,2.1H8Zm2.4,8H3.6V2.8H7V6.3h3.4Z"}})])},zt=[],Pt={name:"DocumentIcon",components:{SVGIcon:L["a"]}},Ht=Pt,Kt=(n("3233"),Object(S["a"])(Ht,Gt,zt,!1,null,"3a80772b",null)),Ut=Kt.exports,Zt=n("de60"),Jt=function(){var t=this,e=t.$createElement,n=t._self._c||e;return n("SVGIcon",{staticClass:"forum-icon",attrs:{viewBox:"0 0 14 14",themeId:"forum"}},[n("path",{attrs:{d:"M13 1v9h-7l-1.5 3-1.5-3h-2v-9zM12 2h-10v7h1.616l0.884 1.763 0.88-1.763h6.62z"}}),n("path",{attrs:{d:"M3 4h8.001v1h-8.001v-1z"}}),n("path",{attrs:{d:"M3 6h8.001v1h-8.001v-1z"}})])},Qt=[],Wt={name:"ForumIcon",components:{SVGIcon:L["a"]}},Xt=Wt,Yt=Object(S["a"])(Xt,Jt,Qt,!1,null,null,null),te=Yt.exports,ee=n("c4dd"),ne=n("86d8"),ie=n("34b0"),se=n("c7ea");const ae={documentation:"documentation",downloads:"downloads",featured:"featured",forums:"forums",sampleCode:"sampleCode",videos:"videos"};var oe={name:"Tile",constants:{Identifier:ae},components:{DestinationDataProvider:se["a"],InlineChevronRightIcon:ie["a"],ContentNode:pt["default"],CurlyBracketsIcon:Bt["a"],DocumentIcon:Ut,DownloadIcon:Zt["a"],ForumIcon:te,PlayIcon:ee["a"],Reference:ne["a"]},props:{action:{type:Object,required:!1},content:{type:Array,required:!0},identifier:{type:String,required:!1},title:{type:String,require:!0}},computed:{iconComponent:({identifier:t})=>({[ae.documentation]:Ut,[ae.downloads]:Zt["a"],[ae.forums]:te,[ae.sampleCode]:Bt["a"],[ae.videos]:ee["a"]}[t])}},re=oe,ce=(n("6899"),Object(S["a"])(re,Ft,Rt,!1,null,"96abac22",null)),le=ce.exports,ue={name:"TileGroup",components:{Tile:le},props:{tiles:{type:Array,required:!0}},computed:{countClass:({tiles:t})=>"count-"+t.length},methods:{propsFor:({action:t,content:e,identifier:n,title:i})=>({action:t,content:e,identifier:n,title:i})}},me=ue,de=(n("f0ca"),Object(S["a"])(me,Mt,Dt,!1,null,"015f9f13",null)),pe=de.exports,he={name:"Resources",mixins:[$t],inject:{store:{default:()=>({setActiveSidebarLink(){},setActiveVolume(){}})}},components:{VolumeName:Lt,TileGroup:pe},computed:{intersectionRootMargin:()=>Ot.topOneThird},props:{content:{type:Array,required:!1},tiles:{type:Array,required:!0}},methods:{onIntersectViewport(){this.store.setActiveSidebarLink("Resources"),this.store.setActiveVolume(null)}}},ve=he,fe=(n("ed64"),Object(S["a"])(ve,It,xt,!1,null,"7f8022c1",null)),be=fe.exports,_e=function(){var t=this,e=t.$createElement,n=t._self._c||e;return n("section",{staticClass:"volume"},[t.name?n("VolumeName",t._b({},"VolumeName",{name:t.name,image:t.image,content:t.content},!1)):t._e(),t._l(t.chapters,(function(e,i){return n("Chapter",{key:e.name,staticClass:"tile",attrs:{content:e.content,image:e.image,name:e.name,number:i+1,topics:t.lookupTopics(e.tutorials),volumeHasName:!!t.name}})}))],2)},ge=[],Ce=function(){var t=this,e=t.$createElement,n=t._self._c||e;return n("section",{staticClass:"chapter",attrs:{id:t.anchor,tabindex:"-1"}},[n("div",{staticClass:"info"},[n("Asset",{attrs:{identifier:t.image,"aria-hidden":"true"}}),n("div",{staticClass:"intro"},[n(t.volumeHasName?"h3":"h2",{tag:"component",staticClass:"name",attrs:{"aria-label":t.name+" - "+t.$tc("tutorials.sections.chapter",{number:t.number})}},[n("span",{staticClass:"eyebrow",attrs:{"aria-hidden":"true"}},[t._v(" "+t._s(t.$t("tutorials.sections.chapter",{number:t.number}))+" ")]),n("span",{staticClass:"name-text",attrs:{"aria-hidden":"true"}},[t._v(t._s(t.name))])]),t.content?n("ContentNode",{attrs:{content:t.content}}):t._e()],1)],1),n("TopicList",{attrs:{topics:t.topics}})],1)},ye=[],Te=function(){var t=this,e=t.$createElement,n=t._self._c||e;return n("ol",{staticClass:"topic-list"},t._l(t.topics,(function(e){return n("li",{key:e.url,staticClass:"topic",class:[t.kindClassFor(e),{"no-time-estimate":!e.estimatedTime}]},[n("div",{staticClass:"topic-icon"},[n(t.iconComponent(e),{tag:"component"})],1),n("router-link",{staticClass:"container",attrs:{to:t.buildUrl(e.url,t.$route.query),"aria-label":t.ariaLabelFor(e)}},[n("div",{staticClass:"link"},[t._v(t._s(e.title))]),e.estimatedTime?n("div",{staticClass:"time"},[n("TimerIcon"),n("span",{staticClass:"time-label"},[t._v(t._s(e.estimatedTime))])],1):t._e()])],1)})),0)},Se=[],Ve=n("a9f1"),ke=n("8d2d");const Ie={article:"article",tutorial:"project"},xe={article:"article",tutorial:"tutorial"},Ne={[Ie.article]:"Article",[Ie.tutorial]:"Tutorial"};var Oe={name:"ChapterTopicList",components:{TimerIcon:gt},constants:{TopicKind:Ie,TopicKindClass:xe,TopicKindIconLabel:Ne},props:{topics:{type:Array,required:!0}},methods:{buildUrl:et["b"],iconComponent:({kind:t})=>({[Ie.article]:Ve["a"],[Ie.tutorial]:ke["a"]}[t]),kindClassFor:({kind:t})=>({[Ie.article]:xe.article,[Ie.tutorial]:xe.tutorial}[t]),formatTime(t){return t.replace("min"," "+this.$t("tutorials.time.minutes.full")).replace("hrs"," "+this.$t("tutorials.time.hours.full"))},ariaLabelFor(t){const{title:e,estimatedTime:n,kind:i}=t,s=[e,Ne[i]];return n&&s.push(`${this.formatTime(n)} ${this.$t("tutorials.estimated-time")}`),s.join(" - ")}}},$e=Oe,je=(n("9792"),Object(S["a"])($e,Te,Se,!1,null,"45ec37c5",null)),we=je.exports,Ae={name:"Chapter",mixins:[$t],inject:{store:{default:()=>({setActiveSidebarLink(){},setActiveVolume(){}})}},components:{Asset:mt["a"],ContentNode:pt["default"],TopicList:we},props:{content:{type:Array,required:!1},image:{type:String,required:!0},name:{type:String,required:!0},number:{type:Number,required:!0},topics:{type:Array,required:!0},volumeHasName:{type:Boolean,default:!1}},computed:{anchor:({name:t})=>Object(g["a"])(t),intersectionRootMargin:()=>Ot.topOneThird},methods:{onIntersectViewport(){this.store.setActiveSidebarLink(this.name),this.volumeHasName||this.store.setActiveVolume(null)}}},qe=Ae,Ee=(n("4230"),Object(S["a"])(qe,Ce,ye,!1,null,"7468bc5e",null)),Le=Ee.exports,Me={name:"Volume",mixins:[$t],components:{VolumeName:Lt,Chapter:Le},computed:{references:({store:t})=>t.state.references,intersectionRootMargin:()=>Ot.topOneThird},inject:{store:{default:()=>({setActiveVolume(){},state:{references:{}}})}},props:{chapters:{type:Array,required:!0},content:{type:Array,required:!1},image:{type:String,required:!1},name:{type:String,required:!1}},methods:{lookupTopics(t){return t.reduce((t,e)=>t.concat(this.references[e]||[]),[])},onIntersectViewport(){this.name&&this.store.setActiveVolume(this.name)}}},De=Me,Fe=(n("b9bf"),Object(S["a"])(De,_e,ge,!1,null,"540dbf10",null)),Re=Fe.exports;const Be={resources:"resources",volume:"volume"};var Ge={name:"LearningPath",components:{Resources:be,TutorialsNavigation:Y,Volume:Re},constants:{SectionKind:Be},inject:{isTargetIDE:{default:!1}},props:{sections:{type:Array,required:!0,validator:t=>t.every(t=>Object.prototype.hasOwnProperty.call(Be,t.kind))}},computed:{classes:({isTargetIDE:t})=>({ide:t}),partitionedSections:({sections:t})=>t.reduce(([t,e],n)=>n.kind===Be.volume?[t.concat(n),e]:[t,e.concat(n)],[[],[]]),volumes:({partitionedSections:t})=>t[0],otherSections:({partitionedSections:t})=>t[1]},methods:{componentFor:({kind:t})=>({[Be.resources]:be,[Be.volume]:Re}[t]),propsFor:({chapters:t,content:e,image:n,kind:i,name:s,tiles:a})=>({[Be.resources]:{content:e,tiles:a},[Be.volume]:{chapters:t,content:e,image:n,name:s}}[i])}},ze=Ge,Pe=(n("aebc"),Object(S["a"])(ze,Vt,kt,!1,null,"69a72bbc",null)),He=Pe.exports;const Ke={hero:"hero",resources:"resources",volume:"volume"};var Ue={name:"TutorialsOverview",components:{Hero:St,LearningPath:He,Nav:rt},mixins:[ct["a"]],constants:{SectionKind:Ke},inject:{isTargetIDE:{default:!1}},props:{metadata:{type:Object,default:()=>({})},references:{type:Object,default:()=>({})},sections:{type:Array,default:()=>[],validator:t=>t.every(t=>Object.prototype.hasOwnProperty.call(Ke,t.kind))}},computed:{pageTitle:({title:t})=>[t,"Tutorials"].filter(Boolean).join(" "),pageDescription:({heroSection:t,extractFirstParagraphText:e})=>t?e(t.content):null,partitionedSections:({sections:t})=>t.reduce(([t,e],n)=>n.kind===Ke.hero?[t.concat(n),e]:[t,e.concat(n)],[[],[]]),heroSections:({partitionedSections:t})=>t[0],otherSections:({partitionedSections:t})=>t[1],heroSection:({heroSections:t})=>t[0],store:()=>m,title:({metadata:{category:t=""}})=>t},provide(){return{store:this.store}},created(){this.store.reset(),this.store.setReferences(this.references)}},Ze=Ue,Je=(n("bc97"),Object(S["a"])(Ze,l,u,!1,null,"08a93885",null)),Qe=Je.exports,We=n("146e"),Xe={name:"TutorialsOverview",components:{Overview:Qe},mixins:[c["a"],We["a"]],data(){return{topicData:null}},computed:{overviewProps:({topicData:{metadata:t,references:e,sections:n}})=>({metadata:t,references:e,sections:n}),topicKey:({$route:t,topicData:e})=>[t.path,e.identifier.interfaceLanguage].join()},beforeRouteEnter(t,e,n){t.meta.skipFetchingData?n(t=>t.newContentMounted()):Object(r["c"])(t,e,n).then(t=>n(e=>{e.topicData=t})).catch(n)},beforeRouteUpdate(t,e,n){Object(r["e"])(t,e)?Object(r["c"])(t,e,n).then(t=>{this.topicData=t,n()}).catch(n):n()},mounted(){this.$bridge.on("contentUpdate",this.handleContentUpdateFromBridge)},beforeDestroy(){this.$bridge.off("contentUpdate",this.handleContentUpdateFromBridge)},watch:{topicData(){this.$nextTick(()=>{this.newContentMounted()})}}},Ye=Xe,tn=Object(S["a"])(Ye,a,o,!1,null,null,null);e["default"]=tn.exports},f0ca:function(t,e,n){"use strict";n("8f86")},f1e6:function(t,e,n){"use strict";n("a0d4")}}]);