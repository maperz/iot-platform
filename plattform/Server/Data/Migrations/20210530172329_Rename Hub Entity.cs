using Microsoft.EntityFrameworkCore.Migrations;

namespace Server.Data.Migrations
{
    public partial class RenameHubEntity : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_AspNetUsers_Projects_HubId",
                table: "AspNetUsers");

            migrationBuilder.DropPrimaryKey(
                name: "PK_Projects",
                table: "Projects");

            migrationBuilder.RenameTable(
                name: "Projects",
                newName: "Hubs");

            migrationBuilder.AddPrimaryKey(
                name: "PK_Hubs",
                table: "Hubs",
                column: "Id");

            migrationBuilder.AddForeignKey(
                name: "FK_AspNetUsers_Hubs_HubId",
                table: "AspNetUsers",
                column: "HubId",
                principalTable: "Hubs",
                principalColumn: "Id",
                onDelete: ReferentialAction.Restrict);
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_AspNetUsers_Hubs_HubId",
                table: "AspNetUsers");

            migrationBuilder.DropPrimaryKey(
                name: "PK_Hubs",
                table: "Hubs");

            migrationBuilder.RenameTable(
                name: "Hubs",
                newName: "Projects");

            migrationBuilder.AddPrimaryKey(
                name: "PK_Projects",
                table: "Projects",
                column: "Id");

            migrationBuilder.AddForeignKey(
                name: "FK_AspNetUsers_Projects_HubId",
                table: "AspNetUsers",
                column: "HubId",
                principalTable: "Projects",
                principalColumn: "Id",
                onDelete: ReferentialAction.Restrict);
        }
    }
}
