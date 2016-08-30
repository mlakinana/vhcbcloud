﻿using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using VHCBCommon.DataAccessLayer;

namespace vhcbcloud
{
    public partial class awardsummary : System.Web.UI.Page
    {
        bool isReallocation = false;

        protected void Page_Load(object sender, EventArgs e)
        {
            string reallocarionFlag = Request.QueryString["Reallocations"];
            isReallocation = reallocarionFlag == "true";

            if (!IsPostBack)
            {
                string projId = Request.QueryString["projectid"];

                DataTable dtProjects = GetProjects();
                BindProjects(dtProjects);

                if (projId != "")
                {
                    lblProjId.Text = GetProjectName(dtProjects, projId);
                    ddlProj.Items.FindByValue(projId).Selected = true;
                    BindAwardSummary(Convert.ToInt32(projId));
                }
            }
        }

        private string GetProjectName(DataTable dtProjects, string projId)
        {
            DataRow[] dr = dtProjects.Select("projectid = '" + projId + "'");
            return dr[0]["Description"].ToString();
        }

        private DataTable GetProjects()
        {
            DataTable dtProjects = new DataTable();
            dtProjects = Project.GetProjects("GetProjects");
            return dtProjects;
        }

        private void BindProjects(DataTable dtProjects)
        {
            ddlProj.DataSource = dtProjects;
            ddlProj.DataValueField = "projectId";
            ddlProj.DataTextField = "Proj_num";
            ddlProj.DataBind();
            ddlProj.Items.Insert(0, new ListItem("Select", "NA"));
        }

        private void BindAwardSummary(int projectid)
        {
            try
            {
                lblErrorMsg.Text = ""; DataTable dtAwdStatus = null; DataTable dtTransDetail = null;
                dtAwdStatus = FinancialTransactions.GetFinancialFundDetailsByProjectId(projectid, isReallocation).Tables[0];
                dtTransDetail = FinancialTransactions.GetFinancialFundDetailsByProjectId(projectid, isReallocation).Tables[1];

                gvCurrentAwdStatus.DataSource = dtAwdStatus;
                gvCurrentAwdStatus.DataBind();

                gvTransDetail.DataSource = dtTransDetail;
                gvTransDetail.DataBind();


                decimal totCommitAmt = 0;
                decimal totPendAmt = 0;
                decimal totExpendAmt = 0;
                decimal totFinalExpendAmt = 0;
                decimal totBalanceAmt = 0;

                if (dtAwdStatus.Rows.Count > 0)
                {
                    Label lblCommit = (Label)gvCurrentAwdStatus.FooterRow.FindControl("lblCommit");
                    Label lblPending = (Label)gvCurrentAwdStatus.FooterRow.FindControl("lblPending");
                    Label lblExpend = (Label)gvCurrentAwdStatus.FooterRow.FindControl("lblExpend");
                    Label lblFinalExpend = (Label)gvCurrentAwdStatus.FooterRow.FindControl("lblFinalExpend");
                    Label lblBalance = (Label)gvCurrentAwdStatus.FooterRow.FindControl("lblBalance");
                    if (dtAwdStatus.Rows.Count > 0)
                    {
                        for (int i = 0; i < dtAwdStatus.Rows.Count; i++)
                        {
                            if (Convert.ToDecimal(dtAwdStatus.Rows[i]["commitmentamount"].ToString()) > 0)
                                totCommitAmt += Convert.ToDecimal(dtAwdStatus.Rows[i]["commitmentamount"].ToString());

                            if (Convert.ToDecimal(dtAwdStatus.Rows[i]["expendedamount"].ToString()) != 0)
                                totExpendAmt += Convert.ToDecimal(dtAwdStatus.Rows[i]["expendedamount"].ToString());

                            if (Convert.ToDecimal(dtAwdStatus.Rows[i]["finaldisbursedamount"].ToString()) != 0)
                                totFinalExpendAmt += Convert.ToDecimal(dtAwdStatus.Rows[i]["finaldisbursedamount"].ToString());

                            if (Convert.ToDecimal(dtAwdStatus.Rows[i]["pendingamount"].ToString()) != 0)
                                totPendAmt += Convert.ToDecimal(dtAwdStatus.Rows[i]["pendingamount"].ToString());

                            if (Convert.ToDecimal(dtAwdStatus.Rows[i]["balance"].ToString()) != 0)
                                totBalanceAmt += Convert.ToDecimal(dtAwdStatus.Rows[i]["balance"].ToString());
                        }
                    }

                    lblCommit.Text = CommonHelper.myDollarFormat(totCommitAmt);
                    lblPending.Text = CommonHelper.myDollarFormat(totPendAmt);
                    lblExpend.Text = CommonHelper.myDollarFormat(totExpendAmt);
                    lblBalance.Text = CommonHelper.myDollarFormat(totBalanceAmt);
                    lblFinalExpend.Text = CommonHelper.myDollarFormat(totFinalExpendAmt);
                }

            }
            catch (Exception ex)
            {
                lblErrorMsg.Text = ex.Message;
            }
        }

        protected void gvCurrentAwdStatus_RowCreated(object sender, GridViewRowEventArgs e)
        {
            e.Row.Cells[0].Visible = false;//isReallocation;

            if (!isReallocation && e.Row.RowType == DataControlRowType.Footer)
            {
                Label l = new Label();
                l.Text = "Totals :";
                e.Row.Cells[2].Controls.Add(l);
            }
        }

        protected void ddlProj_SelectedIndexChanged(object sender, EventArgs e)
        {
            if (ddlProj.SelectedIndex > 0)
            {
                DataTable dtProjects = GetProjects();
                lblProjId.Text = GetProjectName(dtProjects, ddlProj.SelectedValue.ToString());// +" - " + ddlProj.SelectedValue.ToString();
                BindAwardSummary(Convert.ToInt32(ddlProj.SelectedValue.ToString()));
            }
        }
    }
}