(this.webpackJsonpreport=this.webpackJsonpreport||[]).push([[0],{19:function(e,t,a){e.exports=a(51)},24:function(e,t,a){},25:function(e,t,a){},27:function(e,t,a){},46:function(e,t,a){},47:function(e,t,a){},48:function(e,t,a){},49:function(e,t,a){},50:function(e,t,a){},51:function(e,t,a){"use strict";a.r(t);var n=a(0),c=a.n(n),l=a(14),r=a.n(l),o=(a(24),a(2)),i=a(3),s=a(5),u=a(4),m=(a(25),a(7)),d=(a(52),a(1)),p=a.n(d),v=(a(26),a(27),a(11),a(29),function(e){Object(s.a)(a,e);var t=Object(u.a)(a);function a(){return Object(o.a)(this,a),t.apply(this,arguments)}return Object(i.a)(a,[{key:"render",value:function(){return c.a.createElement("svg",{version:"1.1",x:"0px",y:"0px",viewBox:"0 0 1000 1000",enableBackground:"new 0 0 1000 1000"},c.a.createElement("g",null,c.a.createElement("path",{d:"M843,181.5l-343,343l-343-343l-147,147l490,490l490-490L843,181.5z",fill:"white"})))}}]),a}(n.Component)),f=a(16),h=a.n(f),b=(a(36),a(37),a(38),a(39),a(17)),E=a.n(b),y=a(18),k=a.n(y);E.a.vfs=k.a.pdfMake.vfs,window.JSZip=h.a,p.a.DataTable=a(6),a(42),a(44);var O=function(e){Object(s.a)(a,e);var t=Object(u.a)(a);function a(e){var n;return Object(o.a)(this,a),(n=t.call(this)).componentDidMount=function(){var e=n.props,t=e.data,a=e.config,c=e.id,l={paging:t.length>15|(null===a||void 0===a?void 0:a.paging),dom:'<"top"iBf>rt<"bottom"lp><"clear">'};a&&(l=Object(m.a)(Object(m.a)({},l),a));var r="Device Report - ".concat(c);p()("#".concat(c)).DataTable(Object(m.a)(Object(m.a)({},l),{},{buttons:["copyHtml5",{extend:"pdfHtml5",orientation:"landscape",pageSize:"LEGAL",title:r},{extend:"excelHtml5",title:r},{extend:"csvHtml5",title:r}]})),null===a||void 0===a||a.dateFormat;var o=document.querySelector("#".concat(c)).closest(".transition-container");o.addEventListener("onclick",n.setHeight),o.querySelectorAll(".paginate_button").forEach((function(e){e.addEventListener("onclick",n.setHeight)}));var i=document.querySelector("#".concat(c,'_wrapper select[name="').concat(c,'_length"]'));i&&i.addEventListener("onchange",(function(e){}))},n.makeFooter=function(){var e=n.props,t=e.data,a=e.columns,l=e.id;if(t.length>15)return c.a.createElement("tfoot",null,c.a.createElement("tr",null,a.map((function(e){return c.a.createElement("th",{key:"".concat(l).concat(e.Name,"bottom}}")},e.Name)}))))},n.onClick=function(e){var t=e.target.closest(".datatable-container");t.querySelector(".transition-container");t.classList.contains("hidden")?(t.classList.remove("hidden"),e.target.classList.remove("hidden")):(t.classList.add("hidden"),e.target.classList.add("hidden"))},n.setHeight=function(e){var t=n.props.id;document.querySelector("#".concat(t)).closest(".transition-container")},n.state={},n}return Object(i.a)(a,[{key:"render",value:function(){var e=this.props,t=e.data,a=e.columns,n=e.id,l=e.title;e.config;return c.a.createElement("div",{className:"datatable-container"},c.a.createElement("h1",{onClick:this.onClick,className:"collapsable"},c.a.createElement("span",{className:"title"},l),c.a.createElement("div",{className:"expand-icon"},c.a.createElement(v,null))),c.a.createElement("div",{className:"transition-container"},c.a.createElement("div",{className:"datatable-table"},c.a.createElement("table",{id:n,className:"display"},c.a.createElement("thead",null,c.a.createElement("tr",null,a.map((function(e){return c.a.createElement("th",{key:"".concat(n).concat(e.Name,"top}}").concat(Math.random()),className:e.Name.replace(" ","-"),style:e.style},e.Name)})))),c.a.createElement("tbody",null,t.map((function(e,t){return c.a.createElement("tr",{key:"".concat(n).concat(t,"row}}").concat(Math.random())},a.map((function(t){var a=e[t.Value];return t.function&&(a=t.function(a,e)),null==a&&(a="Unknown"),c.a.createElement("td",{key:"".concat(n).concat(t.Name).concat(a,"val}}").concat(Math.random())},a)})))}))),this.makeFooter()))))}}]),a}(n.Component),j=(a(46),a(47),function(e){Object(s.a)(a,e);var t=Object(u.a)(a);function a(){var e;Object(o.a)(this,a);for(var n=arguments.length,c=new Array(n),l=0;l<n;l++)c[l]=arguments[l];return(e=t.call.apply(t,[this].concat(c))).expandAll=function(){document.querySelectorAll(".hidden").forEach((function(e){e.click()}))},e.collapseAll=function(){document.querySelectorAll(".collapsable").forEach((function(e){e.classList.contains("hidden")||e.click()}))},e}return Object(i.a)(a,[{key:"render",value:function(){return c.a.createElement("div",{className:"expand-panel"},c.a.createElement("a",{className:"button expand-btn",onClick:this.expandAll},"Expand All"),c.a.createElement("a",{className:"button collapse-btn",onClick:this.collapseAll},"Collapse All"))}}]),a}(n.Component)),g=(a(48),function(e){Object(s.a)(a,e);var t=Object(u.a)(a);function a(){return Object(o.a)(this,a),t.apply(this,arguments)}return Object(i.a)(a,[{key:"render",value:function(){var e=this.props.panel;return c.a.createElement("div",{className:"overview-panel"},c.a.createElement("div",{className:"title"},c.a.createElement("h1",null,e.title)),c.a.createElement("div",{className:"content"},c.a.createElement("table",null,c.a.createElement("tbody",null,e.data.map((function(e){var t=e.Name,a=e.Value;return null===a&&(a="Unknown"),c.a.createElement("tr",{key:"".concat(t).concat(a),className:"row"},c.a.createElement("td",{className:"key"},t),c.a.createElement("td",{className:"value"},""+a))}))))))}}]),a}(n.Component)),N=(a(49),function(e){Object(s.a)(a,e);var t=Object(u.a)(a);function a(){return Object(o.a)(this,a),t.apply(this,arguments)}return Object(i.a)(a,[{key:"render",value:function(){var e=this.props.data;return c.a.createElement("div",{className:"overview"},e.map((function(e){return c.a.createElement(g,{panel:e,key:e.title})})))}}]),a}(n.Component)),w=(a(50),function(e){Object(s.a)(a,e);var t=Object(u.a)(a);function a(){return Object(o.a)(this,a),t.apply(this,arguments)}return Object(i.a)(a,[{key:"render",value:function(){var e=window.config.Tables;return c.a.createElement("div",{className:"report-data"},e.map((function(e){var t=e.title.replaceAll(" ","-").replaceAll("(","").replaceAll(")","");return null!=e.data.map?c.a.createElement(O,{config:e.options,data:e.data,columns:e.columns,title:e.title,id:t,key:"".concat(e.title,"table}}")}):""})))}}]),a}(n.Component)),x=window.config,A=function(e){Object(s.a)(a,e);var t=Object(u.a)(a);function a(){return Object(o.a)(this,a),t.apply(this,arguments)}return Object(i.a)(a,[{key:"render",value:function(){return c.a.createElement("div",{className:"report"},c.a.createElement("div",{className:"header"},"System Report"),c.a.createElement("div",{className:"body"},c.a.createElement(N,{data:x.Overview}),c.a.createElement(j,null),c.a.createElement(w,null)))}}]),a}(n.Component);var C=function(){return c.a.createElement(A,null)};Boolean("localhost"===window.location.hostname||"[::1]"===window.location.hostname||window.location.hostname.match(/^127(?:\.(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)){3}$/));r.a.render(c.a.createElement(c.a.StrictMode,null,c.a.createElement(C,null)),document.getElementById("root")),"serviceWorker"in navigator&&navigator.serviceWorker.ready.then((function(e){e.unregister()})).catch((function(e){console.error(e.message)}))}},[[19,1,2]]]);
//# sourceMappingURL=main.37ec6947.chunk.js.map