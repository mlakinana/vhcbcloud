﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using VHCBCommon.DataAccessLayer;
using System.Data;

namespace vhcbcloud
{
    public partial class BoardCommitment : System.Web.UI.Page
    {
        DataTable dtProjects;
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                BindProjects();
                BindLkStatus();
                BindLkTransType();
            }
        }

        protected void BindProjects()
        {
            try
            {
                dtProjects = new DataTable();
                dtProjects = Project.GetProjects("GetProjects");
                ddlProjFilter.DataSource = dtProjects;
                ddlProjFilter.DataValueField = "projectId";
                ddlProjFilter.DataTextField = "Proj_num";
                ddlProjFilter.DataBind();
                ddlProjFilter.Items.Insert(0, new ListItem("Select", "NA"));
            }
            catch (Exception ex)
            {
                lblErrorMsg.Text = ex.Message;
            }
        }

        private void BindLkTransType()
        {

            try
            {
                ddlTransType.DataSource = FinancialTransactions.GetLookupDetailsByName("LkTransType");
                ddlTransType.DataValueField = "typeid";
                ddlTransType.DataTextField = "Description";
                ddlTransType.DataBind();
                ddlTransType.Items.Insert(0, new ListItem("Select", "NA"));
            }
            catch (Exception ex)
            {
                lblErrorMsg.Text = ex.Message;
            }
        }

        protected void BindLkStatus()
        {
            try
            {
                ddlStatus.DataSource = FinancialTransactions.GetLookupDetailsByName("LKStatus");
                ddlStatus.DataValueField = "typeid";
                ddlStatus.DataTextField = "Description";
                ddlStatus.DataBind();
                ddlStatus.Items.Insert(0, new ListItem("Select", "NA"));
            }
            catch (Exception ex)
            {
                lblErrorMsg.Text = ex.Message;
            }
        }

        private void BindFundDetails()
        {
            try
            {
                DataTable dtFundDet = FinancialTransactions.GetFundDetailsByProjectId(Convert.ToInt32(ddlProjFilter.SelectedValue.ToString()));
                gvBCommit.DataSource = dtFundDet;
                gvBCommit.DataBind();
            }
            catch (Exception ex)
            {
                lblErrorMsg.Text = ex.Message;
            }
        }

        private void BindSelectedProjects()
        {
            try
            {
                if (ddlProjFilter.SelectedIndex != 0)
                {

                    DataTable dtProjects = FinancialTransactions.GetBoardCommitmentsByProject(Convert.ToInt32(ddlProjFilter.SelectedValue.ToString()));

                    lblProjName.Text = dtProjects.Rows[0]["Description"].ToString();
                    txtGrantee.Text = dtProjects.Rows[0]["Applicantname"].ToString();

                    DataTable dtTrans = FinancialTransactions.GetBoardCommitmentTrans(Convert.ToInt32(ddlProjFilter.SelectedValue.ToString()));
                    if (dtTrans.Rows.Count > 0)
                    {
                        gvPTrans.DataSource = dtTrans;
                        gvPTrans.DataBind();
                        txtTransDate.Text = Convert.ToDateTime( dtTrans.Rows[0]["Date"].ToString()).ToShortDateString();
                        txtTotAmt.Text = dtTrans.Rows[0]["TransAmt"].ToString();
                        ddlStatus.SelectedValue = dtTrans.Rows[0]["lkStatus"].ToString();

                        BindFundDetails();
                    }
                    else
                    {
                        txtTransDate.Text = DateTime.Now.ToShortDateString();
                        txtTotAmt.Text = "";
                        ddlStatus.SelectedIndex = 1;
                        gvPTrans.DataSource = null;
                        gvPTrans.DataBind();
                        gvBCommit.DataSource = null;
                        gvBCommit.DataBind();
                    }
                }
                else
                {
                    lblErrorMsg.Text = "Select a project to proceed";
                }
            }
            catch (Exception ex)
            {
                lblErrorMsg.Text = ex.Message;
            }
        }

        protected void ddlProjFilter_SelectedIndexChanged(object sender, EventArgs e)
        {
            BindSelectedProjects();
        }

        protected void gvBCommit_PageIndexChanging(object sender, GridViewPageEventArgs e)
        {

        }

        protected void gvBCommit_RowCancelingEdit(object sender, GridViewCancelEditEventArgs e)
        {
            gvBCommit.EditIndex = -1;
            BindSelectedProjects();
        }

        protected void gvBCommit_RowUpdating(object sender, GridViewUpdateEventArgs e)
        {

        }

        protected void gvBCommit_RowDataBound(object sender, GridViewRowEventArgs e)
        {
            if ((e.Row.RowState & DataControlRowState.Edit) == DataControlRowState.Edit)
                CommonHelper.GridViewSetFocus(e.Row);
        }

        protected void gvBCommit_RowEditing(object sender, GridViewEditEventArgs e)
        {
            gvBCommit.EditIndex = e.NewEditIndex;
            BindSelectedProjects();
        }

        protected void gvBCommit_Sorting(object sender, GridViewSortEventArgs e)
        {

        }

        protected void btnSubmit_Click(object sender, ImageClickEventArgs e)
        {
            try
            {
                //FinancialTransactions.AddProjectFundDetails();
            }
            catch (Exception ex)
            {
                lblErrorMsg.Text = ex.Message;
            }
        }

        protected void gvPTrans_PageIndexChanging(object sender, GridViewPageEventArgs e)
        {

        }

        protected void gvPTrans_RowCancelingEdit(object sender, GridViewCancelEditEventArgs e)
        {
            gvPTrans.EditIndex = -1;
            BindSelectedProjects();
        }

        protected void gvPTrans_RowEditing(object sender, GridViewEditEventArgs e)
        {
            gvPTrans.EditIndex = e.NewEditIndex;
            BindSelectedProjects();
        }

        protected void gvPTrans_RowUpdating(object sender, GridViewUpdateEventArgs e)
        {

        }

        protected void gvPTrans_Sorting(object sender, GridViewSortEventArgs e)
        {
            SortExpression = e.SortExpression;
            DataTable dtTrans = new DataTable();
            if (ddlProjFilter.SelectedIndex != 0)
            {

                DataTable dtProjects = FinancialTransactions.GetBoardCommitmentsByProject(Convert.ToInt32(ddlProjFilter.SelectedValue.ToString()));

                lblProjName.Text = dtProjects.Rows[0]["Description"].ToString();
                txtGrantee.Text = dtProjects.Rows[0]["Applicantname"].ToString();

                dtTrans = FinancialTransactions.GetBoardCommitmentTrans(Convert.ToInt32(ddlProjFilter.SelectedValue.ToString()));
                if (dtTrans.Rows.Count > 0)
                {
                    gvPTrans.DataSource = dtTrans;
                    gvPTrans.DataBind();
                }
            }
            SortDireaction = CommonHelper.GridSorting(gvBCommit, dtTrans, SortExpression, SortDireaction);
        }

        protected void gvPTrans_RowDataBound(object sender, GridViewRowEventArgs e)
        {
            if ((e.Row.RowState & DataControlRowState.Edit) == DataControlRowState.Edit)
                CommonHelper.GridViewSetFocus(e.Row);

            //Checking whether the Row is Data Row
            if (e.Row.RowType == DataControlRowType.DataRow)
            {
                //Finding the Dropdown control.
                DropDownList ddlTtype = (e.Row.FindControl("ddlTransType") as DropDownList);
                if (ddlTtype != null)
                {
                    ddlTtype.DataSource = FinancialTransactions.GetLookupDetailsByName("LKStatus");
                    ddlTtype.DataValueField = "typeid";
                    ddlTtype.DataTextField = "Description";
                    ddlTtype.DataBind();
                }
                TextBox txtTtype = e.Row.FindControl("txtTransStatus") as TextBox;
                if (txtTtype != null)
                {
                    ddlTtype.Items.FindByValue(txtTtype.Text).Selected = true;
                }
            }
        }

        public string SortDireaction
        {
            get
            {
                if (ViewState["SortDireaction"] == null)
                    return string.Empty;
                else
                    return ViewState["SortDireaction"].ToString() == "ASC" ? "DESC" : "ASC";
            }
            set
            {
                ViewState["SortDireaction"] = value;
            }
        }

        public string SortExpression
        {
            get
            {
                if (ViewState["SortExpression"] == null)
                    return string.Empty;
                else
                    return ViewState["SortExpression"].ToString();
            }
            set
            {
                ViewState["SortExpression"] = value;
            }
        }
    }
}