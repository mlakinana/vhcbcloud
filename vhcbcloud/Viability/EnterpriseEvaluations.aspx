﻿<%@ Page Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="EnterpriseEvaluations.aspx.cs"
    Inherits="vhcbcloud.Viability.EnterpriseEvaluations" MaintainScrollPositionOnPostback="true" %>

<asp:Content ID="EventContent" ContentPlaceHolderID="MainContent" runat="server">
    <div class="jumbotron" id="vhcb">
        <!-- Tabs -->
        <div id="dvTabs" runat="server">
            <div id="page-inner">
                <div id="VehicleDetail">
                    <ul class="vdp-tabs" runat="server" id="Tabs"></ul>
                </div>
            </div>
        </div>

        <div class="container">
            <div class="panel panel-default">
                <div class="panel-heading">
                    <table style="width: 100%;">
                        <tr>
                            <td><span class="labelClass">Project #</span></td>
                            <td>
                                <span class="labelClass" id="ProjectNum" runat="server"></span>
                            </td>
                            <td><span class="labelClass">Name</span></td>
                            <td style="text-align: left">
                                <span class="labelClass" id="ProjName" runat="server"></span>
                            </td>
                            <td>
                                <%--<asp:CheckBox ID="cbLatestBudget" runat="server" Checked="true" Text=" Is Latest Budget" />--%>
                            </td>
                            <td style="text-align: right">
                                <asp:ImageButton ID="imgSearch" ImageUrl="~/Images/search.png" ToolTip="Project Search"
                                    Style="border: none; vertical-align: middle;" runat="server" Text="Project Search"
                                    OnClientClick="window.location.href='../ProjectSearch.aspx'; return false;"></asp:ImageButton>
                                <asp:ImageButton ID="ibAwardSummary" runat="server" ImageUrl="~/Images/$$.png" Text="Award Summary" Style="border: none; vertical-align: middle;"
                                    OnClientClick="PopupAwardSummary(); return false;"></asp:ImageButton>
                                <asp:ImageButton ID="btnProjectNotes" runat="server" ImageUrl="~/Images/notes.png" Text="Project Notes" Style="border: none; vertical-align: middle;" />
                                <asp:CheckBox ID="cbActiveOnly" runat="server" Text="Active Only" Checked="true" AutoPostBack="true"
                                    OnCheckedChanged="cbActiveOnly_CheckedChanged" />
                            </td>
                        </tr>
                        <tr>
                            <td colspan="6" style="height: 5px"></td>
                        </tr>
                    </table>
                </div>

                <ajaxToolkit:ModalPopupExtender ID="mpExtender" runat="server" PopupControlID="pnlProjectNotes" TargetControlID="btnProjectNotes" CancelControlID="btnClose"
                    BackgroundCssClass="MEBackground">
                </ajaxToolkit:ModalPopupExtender>

                <asp:Panel ID="pnlProjectNotes" runat="server" CssClass="MEPopup" align="center" Style="display: none">
                    <iframe style="width: 750px; height: 600px;" id="ifProjectNotes" src="../ProjectNotes.aspx" runat="server"></iframe>
                    <br />
                    <asp:Button ID="btnClose" runat="server" Text="Close" class="btn btn-info" />
                </asp:Panel>

                <div id="dvMessage" runat="server">
                    <p class="lblErrMsg">&nbsp;&nbsp;&nbsp;<asp:Label runat="server" ID="lblErrorMsg"></asp:Label></p>
                </div>

                <div class="panel-width" runat="server" id="dvNewEntMilestones">
                    <div class="panel panel-default ">
                        <div class="panel-heading ">
                            <table style="width: 100%;">
                                <tr>
                                    <td>
                                        <h3 class="panel-title">Milestones</h3>
                                    </td>
                                    <td style="text-align: right">
                                        <asp:CheckBox ID="cbAddMilestone" runat="server" Text="Add New Milestone" />
                                    </td>
                                </tr>
                            </table>
                        </div>

                        <div class="panel-body" runat="server" id="dvEntMilestoneForm">
                            <asp:Panel runat="server" ID="Panel2">
                                <table style="width: 100%">
                                    <tr>
                                        <td style="width: 43px"><span class="labelClass">Milestone</span></td>
                                        <td style="width: 93px">
                                            <asp:DropDownList ID="ddlMilestone" CssClass="clsDropDown" runat="server"></asp:DropDownList>
                                        </td>
                                        <td style="width: 30px">
                                            <span class="labelClass">Date</span>
                                        </td>
                                        <td style="width: 176px">
                                            <asp:TextBox ID="txtDate" CssClass="clsTextBoxBlueSm" runat="server"></asp:TextBox>
                                            <ajaxToolkit:CalendarExtender runat="server" ID="CalendarExtender1" TargetControlID="txtDate">
                                            </ajaxToolkit:CalendarExtender>
                                        </td>
                                        <td style="width: 134px"></td>
                                        <td class="modal-sm" style="width: 115px"></td>
                                    </tr>
                                    <tr>
                                        <td colspan="6" style="height: 5px"></td>
                                    </tr>
                                    <tr>
                                        <td style="width: 163px" colspan="6"><span class="labelClass">Comments:</span></td>
                                    </tr>
                                    <tr>
                                        <td colspan="6" style="height: 5px"></td>
                                    </tr>
                                    <tr>
                                        <td colspan="6">
                                            <asp:TextBox ID="txtComments" TextMode="multiline" CssClass="clsTextBoxBlue1" Columns="50" Rows="2" runat="server" Width="100%" Height="80px" />
                                        </td>
                                    </tr>
                                    <tr>
                                        <td colspan="6" style="height: 5px"></td>
                                    </tr>
                                    <tr>
                                        <td style="width: 163px" colspan="6"><span class="labelClass">Please describe the experience working with your lead planning advisor:</span></td>
                                    </tr>
                                    <tr>
                                        <td colspan="6" style="height: 5px"></td>
                                    </tr>
                                    <tr>
                                        <td colspan="6">
                                            <asp:TextBox ID="txtLeadPlanAdvisorExp" TextMode="multiline" CssClass="clsTextBoxBlue1" Columns="50" Rows="2" runat="server" Width="100%" Height="80px" />
                                        </td>
                                    </tr>
                                    <tr>
                                        <td colspan="6" style="height: 5px"></td>
                                    </tr>
                                    <tr>
                                        <td style="width: 163px" colspan="6"><span class="labelClass">Has the business planning process or the written plan helped in applying for or obtaining financing (loans, grants, etc)?</span></td>
                                    </tr>
                                    <tr>
                                        <td colspan="6" style="height: 5px"></td>
                                    </tr>
                                    <tr>
                                        <td style="width: 163px" colspan="5">
                                            <asp:RadioButtonList ID="rdBtnPlanProcess" runat="server" RepeatDirection="Horizontal">
                                                <asp:ListItem>Yes</asp:ListItem>
                                                <asp:ListItem>No</asp:ListItem>
                                            </asp:RadioButtonList>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td colspan="6" style="height: 5px"></td>
                                    </tr>
                                    <tr>
                                        <td colspan="6" style="height: 5px">
                                            <div class="panel-width" runat="server" id="Div1">
                                                <div class="panel panel-default ">
                                                    <div class="panel-heading ">
                                                        <h3 class="panel-title" style="font-size: small">Financing that was Secured</h3>
                                                    </div>

                                                    <div class="panel-body">
                                                        <table style="width: 100%">
                                                            <tr>
                                                                <td style="width: 83px"><span><strong>Loans</strong>:</span></td>
                                                                <td style="width: 111px"><span class="labelClass">Requested:</span></td>
                                                                <td style="width: 142px">
                                                                    <asp:TextBox ID="txtLoanReq" CssClass="clsTextBoxBlueSm" runat="server"></asp:TextBox></td>
                                                                <td style="width: 93px"><span class="labelClass">Received:</span></td>
                                                                <td style="width: 141px">
                                                                    <asp:TextBox ID="txtLoanRec" CssClass="clsTextBoxBlueSm" runat="server"></asp:TextBox></td>
                                                                <td style="width: 93px"><span class="labelClass">Pending:</span></td>
                                                                <td>
                                                                    <asp:CheckBox ID="cbLoanPending" runat="server" Text="" />
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <td colspan="7" style="height: 5px"></td>
                                                            </tr>
                                                            <tr>
                                                                <td style="width: 83px"><span><strong>Grants</strong>:</span></td>
                                                                <td style="width: 111px"><span class="labelClass">Requested:</span></td>
                                                                <td style="width: 142px">
                                                                    <asp:TextBox ID="txtGrantsReq" CssClass="clsTextBoxBlueSm" runat="server"></asp:TextBox></td>
                                                                <td style="width: 93px"><span class="labelClass">Received:</span></td>
                                                                <td style="width: 141px">
                                                                    <asp:TextBox ID="txtGrantsRec" CssClass="clsTextBoxBlueSm" runat="server"></asp:TextBox></td>
                                                                <td style="width: 93px"><span class="labelClass">Pending:</span></td>
                                                                <td>
                                                                    <asp:CheckBox ID="cbGrantsPending" runat="server" Text="" />
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <td colspan="7" style="height: 5px"></td>
                                                            </tr>
                                                            <tr>
                                                                <td style="width: 83px"><span><strong>Other</strong>:</span></td>
                                                                <td style="width: 111px"><span class="labelClass">Requested:</span></td>
                                                                <td style="width: 142px">
                                                                    <asp:TextBox ID="txtOtherReq" CssClass="clsTextBoxBlueSm" runat="server"></asp:TextBox></td>
                                                                <td style="width: 93px"><span class="labelClass">Received:</span></td>
                                                                <td style="width: 141px">
                                                                    <asp:TextBox ID="txtOtherRec" CssClass="clsTextBoxBlueSm" runat="server"></asp:TextBox></td>
                                                                <td style="width: 93px"><span class="labelClass">Pending:</span></td>
                                                                <td>
                                                                    <asp:CheckBox ID="cbOtherPending" runat="server" Text="" />
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <td colspan="7" style="height: 5px"></td>
                                                            </tr>
                                                        </table>
                                                    </div>
                                                </div>
                                            </div>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td style="width: 163px" colspan="6"><span class="labelClass">Please share any additional positive outcomes or changes that have taken place in relation to your work with the Vermont Farm Viability Program.  You can also use this space if you have any additional comments, questions, or ideas to share with the program evaluation team.
                                        </span></td>
                                    </tr>
                                    <tr>
                                        <td colspan="6" style="height: 5px"></td>
                                    </tr>
                                    <tr>
                                        <td colspan="6">
                                            <asp:TextBox ID="txtSharedOutcome" TextMode="multiline" CssClass="clsTextBoxBlue1" Columns="50" Rows="2" runat="server" Width="100%" Height="80px" />
                                        </td>
                                    </tr>
                                    <tr>
                                        <td style="width: 163px" colspan="6"><span class="labelClass">Finally, may we use quotes from your responses to this questionnaire in our publicity or reports to funders?</span></td>
                                    </tr>
                                    <tr>
                                        <td colspan="6" style="height: 5px"></td>
                                    </tr>
                                    <tr>
                                        <td colspan="6">
                                            <asp:DropDownList ID="ddlQuoteUse" CssClass="clsTextBoxBlueSm" Width="200px" runat="server"></asp:DropDownList>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td colspan="6" style="height: 5px"></td>
                                    </tr>
                                    <tr>
                                        <td style="width: 43px">Active:</td>
                                        <td class="modal-sm" style="width: 115px" colspan="5">
                                            <asp:CheckBox ID="chkMilestoneActive" Enabled="false" runat="server" Checked="true" />
                                        </td>
                                    </tr>
                                    <tr>
                                        <td style="width: 43px">
                                            <asp:Button ID="btnAddEntMilestone" runat="server" Text="Submit" class="btn btn-info"
                                                OnClick="btnAddEntMilestone_Click" />
                                        </td>
                                        <td style="width: 93px"> <asp:Button ID="btnClear" runat="server" Text="Cancel" class="btn btn-info"
                                                OnClick="btnClear_Click" /></td>
                                        <td style="width: 30px"></td>
                                        <td style="width: 176px"></td>
                                        <td style="width: 134px"></td>
                                        <td class="modal-sm" style="width: 115px"></td>
                                    </tr>
                                    <tr>
                                        <td colspan="6" style="height: 5px"></td>
                                    </tr>
                                </table>
                            </asp:Panel>
                        </div>

                        <div class="panel-body" id="dvEntMilestoneGrid" runat="server">
                            <asp:Panel runat="server" ID="Panel3" Width="100%" Height="170px" ScrollBars="Vertical">
                                <asp:GridView ID="gvEntMilestoneGrid" runat="server" AutoGenerateColumns="False"
                                    Width="100%" CssClass="gridView" PageSize="50" PagerSettings-Mode="NextPreviousFirstLast"
                                    GridLines="None" EnableTheming="True" AllowPaging="false"
                                    OnRowEditing="gvEntMilestoneGrid_RowEditing" OnRowCancelingEdit="gvEntMilestoneGrid_RowCancelingEdit"
                                    OnRowDataBound="gvEntMilestoneGrid_RowDataBound">
                                    <AlternatingRowStyle CssClass="alternativeRowStyle" />
                                    <PagerStyle CssClass="pagerStyle" ForeColor="#F78B0E" />
                                    <HeaderStyle CssClass="headerStyle" />
                                    <PagerSettings Mode="NumericFirstLast" FirstPageText="&amp;lt;" LastPageText="&amp;gt;" PageButtonCount="5" />
                                    <RowStyle CssClass="rowStyle" />
                                    <Columns>
                                        <asp:TemplateField HeaderText="EnterpriseEvalID" Visible="false">
                                            <ItemTemplate>
                                                <asp:Label ID="lblEnterpriseEvalID" runat="Server" Text='<%# Eval("EnterpriseEvalID") %>' />
                                            </ItemTemplate>
                                        </asp:TemplateField>
                                        <asp:TemplateField ItemStyle-HorizontalAlign="Center" HeaderText="Select">
                                            <ItemTemplate>
                                                <asp:RadioButton ID="rdBtnSelectEntMilestone" runat="server" AutoPostBack="true" onclick="RadioCheck(this);"
                                                    OnCheckedChanged="rdBtnSelectEntMilestone_CheckedChanged" />
                                                <asp:HiddenField ID="HiddenEnterpriseEvalID" runat="server" Value='<%#Eval("EnterpriseEvalID")%>' />
                                            </ItemTemplate>
                                            <ItemStyle HorizontalAlign="Center" Width="70px"></ItemStyle>
                                        </asp:TemplateField>
                                        <asp:TemplateField HeaderText="Milestone">
                                            <ItemTemplate>
                                                <asp:Label ID="lblMilestone" runat="Server" Text='<%# Eval("MilestoneDesc") %>' />
                                            </ItemTemplate>
                                        </asp:TemplateField>
                                        <asp:TemplateField HeaderText="Date">
                                            <ItemTemplate>
                                                <asp:Label ID="lblDate" runat="Server" Text='<%# Eval("MSDate", "{0:MM/dd/yyyy}") %>' />
                                            </ItemTemplate>
                                        </asp:TemplateField>
                                        <asp:TemplateField HeaderText="Comments">
                                            <ItemTemplate>
                                                <asp:Label ID="lblNotes" runat="Server" ToolTip='<%# Eval("Comment") %>' Text='<%# Eval("ShortComment") %>' />
                                            </ItemTemplate>
                                        </asp:TemplateField>
                                        <asp:TemplateField HeaderText="Active">
                                            <ItemTemplate>
                                                <asp:CheckBox ID="chkActive" Enabled="false" runat="server" Checked='<%# Eval("RowIsActive") %>' />
                                            </ItemTemplate>
                                        </asp:TemplateField>
                                        <asp:CommandField ShowEditButton="True" />
                                    </Columns>
                                </asp:GridView>
                            </asp:Panel>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
    <asp:HiddenField ID="hfProjectId" runat="server" />
    <asp:HiddenField ID="hfEnterpriseEvalID" runat="server" />


    <script language="javascript">
        $(document).ready(function () {
            CurrencyControls();

            $('#<%= dvEntMilestoneForm.ClientID%>').toggle($('#<%= cbAddMilestone.ClientID%>').is(':checked'));
            $('#<%= cbAddMilestone.ClientID%>').click(function () {
                $('#<%= dvEntMilestoneForm.ClientID%>').toggle(this.checked);
            }).change();
        });

        function CurrencyControls() {
            toCurrencyControl($('#<%= txtLoanReq.ClientID%>').val(), $('#<%= txtLoanReq.ClientID%>'));
            toCurrencyControl($('#<%= txtLoanRec.ClientID%>').val(), $('#<%= txtLoanRec.ClientID%>'));
            toCurrencyControl($('#<%= txtOtherReq.ClientID%>').val(), $('#<%= txtOtherReq.ClientID%>'));
            toCurrencyControl($('#<%= txtOtherRec.ClientID%>').val(), $('#<%= txtOtherRec.ClientID%>'));
            toCurrencyControl($('#<%= txtGrantsReq.ClientID%>').val(), $('#<%= txtGrantsReq.ClientID%>'));
            toCurrencyControl($('#<%= txtGrantsRec.ClientID%>').val(), $('#<%= txtGrantsRec.ClientID%>'));

            $('#<%= txtLoanReq.ClientID%>').keyup(function () {
                toCurrencyControl($('#<%= txtLoanReq.ClientID%>').val(), $('#<%= txtLoanReq.ClientID%>'));
            });
            $('#<%= txtLoanRec.ClientID%>').keyup(function () {
                toCurrencyControl($('#<%= txtLoanRec.ClientID%>').val(), $('#<%= txtLoanRec.ClientID%>'));
            });

            $('#<%= txtOtherReq.ClientID%>').keyup(function () {
                toCurrencyControl($('#<%= txtOtherReq.ClientID%>').val(), $('#<%= txtOtherReq.ClientID%>'));
            });
            $('#<%= txtOtherRec.ClientID%>').keyup(function () {
                toCurrencyControl($('#<%= txtOtherRec.ClientID%>').val(), $('#<%= txtOtherRec.ClientID%>'));
            });

            $('#<%= txtGrantsReq.ClientID%>').keyup(function () {
                toCurrencyControl($('#<%= txtGrantsReq.ClientID%>').val(), $('#<%= txtGrantsReq.ClientID%>'));
             });
             $('#<%= txtGrantsRec.ClientID%>').keyup(function () {
                toCurrencyControl($('#<%= txtGrantsRec.ClientID%>').val(), $('#<%= txtGrantsRec.ClientID%>'));
            });
        }
        function RadioCheck(rb) {
            var gv = document.getElementById("<%=gvEntMilestoneGrid.ClientID%>");
            var rbs = gv.getElementsByTagName("input");

            var row = rb.parentNode.parentNode;
            for (var i = 0; i < rbs.length; i++) {
                if (rbs[i].type == "radio") {
                    if (rbs[i].checked && rbs[i] != rb) {
                        rbs[i].checked = false;
                        break;
                    }
                }
            }
        }

        function PopupAwardSummary() {
            window.open('../awardsummary.aspx?projectid=' + $('#<%=hfProjectId.ClientID%>').val());
        };
    </script>
</asp:Content>

