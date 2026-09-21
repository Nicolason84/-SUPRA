import SwiftUI

private struct OrganizationDepartment: Identifiable {
    let id: String
    let code: String
    let name: String
    let mission: String
    let kpi: String
    let alonso: String
    let accent: Color
}

struct OrganizationPeopleView: View {
    private let departments: [OrganizationDepartment] = [
        .init(id: "D00", code: "EXEC", name: "Executive & Governance", mission: "Strategy, capital, authority and arbitration.", kpi: "Cash · Revenue · Risk", alonso: "L6–L7", accent: .purple),
        .init(id: "D01", code: "REV", name: "Commercial & Revenue", mission: "Verified problems → signed business → cash.", kpi: "Pipeline · Win rate · Cash", alonso: "L5–L6", accent: .green),
        .init(id: "D02", code: "MKT", name: "Marketing, Brand & Communications", mission: "Create demand, trust and market legibility.", kpi: "Inbound · Conversion · CAC", alonso: "L5–L6", accent: .pink),
        .init(id: "D03", code: "PRD", name: "Product & Portfolio", mission: "Choose what to build, for whom and why.", kpi: "Value · Usage · Margin", alonso: "L4–L6", accent: .blue),
        .init(id: "D04", code: "R&D", name: "I+D / R&D / Innovation", mission: "Real limits → experiments → proven capability.", kpi: "Experiments · Transfer", alonso: "L4–L7", accent: .indigo),
        .init(id: "D05", code: "ENG", name: "Engineering, AI & Platform", mission: "Build and operate software, AI and runtime.", kpi: "Build · Release · MTTR", alonso: "L2–L7", accent: .cyan),
        .init(id: "D06", code: "CAN", name: "CAnnoNico, Data, Knowledge & Evidence", mission: "One provable memory and organizational truth.", kpi: "Canon · Provenance · Recall", alonso: "L4", accent: .mint),
        .init(id: "D07", code: "IND", name: "Hardware, Industrialization & Supply", mission: "Physical concepts → reliable deliverable products.", kpi: "Cost · Yield · Quality", alonso: "L1–L5", accent: .orange),
        .init(id: "D08", code: "OPS", name: "Operations, Delivery & PMO", mission: "Sold work → successful evidenced delivery.", kpi: "OTD · Cycle · Margin", alonso: "L5", accent: .teal),
        .init(id: "D09", code: "CS", name: "Customer Success, Support & Quality", mission: "Customer value → feedback → improvement.", kpi: "TTV · Renewal · Support", alonso: "L5–L6", accent: .yellow),
        .init(id: "D10", code: "FIN", name: "Finance, Admin & Procurement", mission: "Protect cash and maintain financial truth.", kpi: "Cash · DSO · Margin", alonso: "L5–L7", accent: .green),
        .init(id: "D11", code: "LGL", name: "Legal, Compliance, IP & Risk", mission: "Protect company, customers, data and IP.", kpi: "Risk · Contracts · Compliance", alonso: "L1–L7", accent: .red),
        .init(id: "D12", code: "PPL", name: "People / RH & Organization", mission: "Build the smallest capable human organization.", kpi: "Capacity · Role coverage", alonso: "L6–L7", accent: .purple),
        .init(id: "D13", code: "PRT", name: "Partnerships, Ecosystem & International", mission: "Extend reach through channels and alliances.", kpi: "Partner revenue · Reach", alonso: "L5–L7", accent: .blue)
    ]

    private let columns = [
        GridItem(.adaptive(minimum: 260, maximum: 360), spacing: 16)
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                hero
                truthStrip
                companyFlow
                departmentGrid
                workforceContract
                hiringGate
            }
            .padding(28)
            .frame(maxWidth: 1500, alignment: .leading)
            .frame(maxWidth: .infinity)
        }
        .background(
            LinearGradient(
                colors: [
                    Color.green.opacity(0.08),
                    Color(nsColor: .windowBackgroundColor),
                    Color(nsColor: .windowBackgroundColor)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .navigationTitle("Organization / People")
    }

    private var hero: some View {
        HStack(alignment: .top, spacing: 24) {
            VStack(alignment: .leading, spacing: 8) {
                Text("NOVA ERA ORGANIZATION")
                    .font(.caption.weight(.bold))
                    .tracking(1.7)
                    .foregroundStyle(.green)
                Text("One company. Many departments. One human authority model.")
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                Text("Humans, contractors and digital support circulate through one provable operating system — without fake headcount.")
                    .font(.title3)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: 860, alignment: .leading)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 8) {
                metric("14", "departments")
                metric("1", "canonical org graph")
                metric("0", "invented employees")
            }
        }
        .padding(24)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.green.opacity(0.20))
        )
    }

    private var truthStrip: some View {
        HStack(spacing: 12) {
            truthBadge("LEGAL", "Evidence only", "building.2.fill")
            truthBadge("HUMAN", "Staff / contractors", "person.2.fill")
            truthBadge("OPERATING", "Departments / roles", "square.grid.3x3.fill")
            truthBadge("DIGITAL", "SUPRA support ≠ employee", "cpu.fill")
        }
    }

    private var companyFlow: some View {
        section("Company circulation", symbol: "arrow.triangle.2.circlepath") {
            HStack(spacing: 8) {
                flowNode("Market")
                arrow
                flowNode("Revenue")
                arrow
                flowNode("Product")
                arrow
                flowNode("R&D")
                arrow
                flowNode("Build")
                arrow
                flowNode("Delivery")
                arrow
                flowNode("Cash")
                arrow
                flowNode("Learning")
                arrow
                flowNode("Canon")
            }
            .padding(.vertical, 4)
        }
    }

    private var departmentGrid: some View {
        section("Departments", symbol: "person.3.fill") {
            LazyVGrid(columns: columns, alignment: .leading, spacing: 16) {
                ForEach(departments) { department in
                    departmentCard(department)
                }
            }
        }
    }

    private var workforceContract: some View {
        section("Workforce contract", symbol: "person.badge.shield.checkmark.fill") {
            HStack(alignment: .top, spacing: 16) {
                contractCard(
                    title: "Human accountability",
                    text: "Strategy, signatures, money, hiring, security boundaries and irreversible acts remain human-gated.",
                    icon: "person.crop.circle.badge.checkmark"
                )
                contractCard(
                    title: "Digital support",
                    text: "SUPRA may research, analyze, draft, classify, test, monitor and execute reversible actions inside explicit authority.",
                    icon: "cpu.fill"
                )
                contractCard(
                    title: "No fake headcount",
                    text: "A department can exist as an operating domain while its human seats remain vacant, contractor-based or future hires.",
                    icon: "checkmark.seal.fill"
                )
            }
        }
    }

    private var hiringGate: some View {
        section("Hiring law", symbol: "person.crop.circle.badge.plus") {
            VStack(alignment: .leading, spacing: 14) {
                Text("Hire only after a proven bottleneck survives simplification, automation, reuse, process repair and external support.")
                    .font(.headline)

                HStack(spacing: 10) {
                    gate("Problem")
                    arrow
                    gate("Evidence")
                    arrow
                    gate("Automate")
                    arrow
                    gate("Alternatives")
                    arrow
                    gate("Role")
                    arrow
                    gate("90-day outcome")
                    arrow
                    gate("Continue / stop")
                }
            }
            .padding(18)
            .background(Color.green.opacity(0.06), in: RoundedRectangle(cornerRadius: 18))
        }
    }

    private func departmentCard(_ department: OrganizationDepartment) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(department.code)
                    .font(.caption2.weight(.heavy))
                    .tracking(1.2)
                    .foregroundStyle(department.accent)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 5)
                    .background(department.accent.opacity(0.12), in: Capsule())

                Spacer()

                Text(department.alonso)
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(.secondary)
            }

            Text(department.name)
                .font(.headline)

            Text(department.mission)
                .font(.callout)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)

            Divider()

            Label(department.kpi, systemImage: "chart.line.uptrend.xyaxis")
                .font(.caption)
                .foregroundStyle(department.accent)
        }
        .padding(17)
        .frame(maxWidth: .infinity, minHeight: 165, alignment: .topLeading)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(department.accent.opacity(0.16))
        )
    }

    private func section<Content: View>(
        _ title: String,
        symbol: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            Label(title, systemImage: symbol)
                .font(.title3.bold())
            content()
        }
    }

    private func truthBadge(_ title: String, _ subtitle: String, _ icon: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .foregroundStyle(.green)
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.caption.weight(.bold))
                Text(subtitle).font(.caption2).foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(12)
        .frame(maxWidth: .infinity)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 14))
    }

    private func contractCard(title: String, text: String, icon: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(.green)
            Text(title).font(.headline)
            Text(text)
                .font(.callout)
                .foregroundStyle(.secondary)
        }
        .padding(18)
        .frame(maxWidth: .infinity, minHeight: 160, alignment: .topLeading)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 18))
    }

    private func metric(_ value: String, _ label: String) -> some View {
        HStack(spacing: 8) {
            Text(value)
                .font(.title3.bold())
                .foregroundStyle(.green)
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private func flowNode(_ text: String) -> some View {
        Text(text)
            .font(.caption.weight(.semibold))
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background(.regularMaterial, in: Capsule())
    }

    private func gate(_ text: String) -> some View {
        Text(text)
            .font(.caption2.weight(.semibold))
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .background(Color.green.opacity(0.10), in: Capsule())
    }

    private var arrow: some View {
        Image(systemName: "arrow.right")
            .font(.caption.bold())
            .foregroundStyle(.secondary)
    }
}

#Preview {
    OrganizationPeopleView()
        .frame(width: 1280, height: 900)
}
