import SwiftUI

enum FilterID: String, CaseIterable {
    case sort, openNow, points, offers
}

struct HomeFilterChipsView: View {
    @Binding var sortOrder: HomeView.SortOrder
    @Binding var showOnlyOpen: Bool
    @Binding var showOnlyPoints: Bool
    @Binding var showOnlyOffers: Bool
    
    // Referencia al orden original para restaurar posiciones
    private let initialOrder: [FilterID] = FilterID.allCases
    
    // El orden de los filtros se gestiona dinámicamente
    @State private var filterOrder: [FilterID] = FilterID.allCases
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(filterOrder, id: \.self) { filter in
                    viewForFilter(filter)
                }
            }
            .padding(.horizontal, 16)
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: filterOrder)
    }
    
    @ViewBuilder
    private func viewForFilter(_ filter: FilterID) -> some View {
        switch filter {
        case .sort:
            sortChip
        case .openNow:
            openNowChip
        case .points:
            pointsChip
        case .offers:
            offersChip
        }
    }
    
    private var sortChip: some View {
        Menu {
            Button {
                withAnimation { 
                    sortOrder = .closest
                    updatePosition(.sort, isActive: false)
                }
            } label: {
                Label("Más cerca", systemImage: sortOrder == .closest ? "checkmark" : "mappin.and.ellipse")
            }
            
            Button {
                withAnimation { 
                    sortOrder = .farthest
                    updatePosition(.sort, isActive: true)
                }
            } label: {
                Label("Más lejos", systemImage: sortOrder == .farthest ? "checkmark" : "location.slash")
            }

            Divider()

            Button {
                withAnimation { 
                    sortOrder = .bestRated
                    updatePosition(.sort, isActive: true)
                }
            } label: {
                Label("Mejor valorados", systemImage: sortOrder == .bestRated ? "checkmark" : "star.fill")
            }

            Button {
                withAnimation { 
                    sortOrder = .worstRated
                    updatePosition(.sort, isActive: true)
                }
            } label: {
                Label("Peor valorados", systemImage: sortOrder == .worstRated ? "checkmark" : "star.leadinghalf.filled")
            }
        } label: {
            HStack(spacing: 6) {
                Image(systemName: "arrow.up.arrow.down")
                    .font(.system(size: 11, weight: .bold))
                Text("Ordenar")
                if sortOrder != .closest {
                    Circle().fill(Color.white).frame(width: 5, height: 5)
                }
            }
            .font(.system(size: 13, weight: .bold, design: .rounded))
            .foregroundStyle(sortOrder != .closest ? .white : .primary)
            .padding(.horizontal, 16)
            .frame(height: 38)
            .background(sortOrder != .closest ? Color.brandGranate : Color.primary.opacity(0.06))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
    }
    
    private var openNowChip: some View {
        filterChip(isSelected: showOnlyOpen) {
            Text("Abierto Ahora")
        } action: {
            withAnimation(.spring()) {
                showOnlyOpen.toggle()
                updatePosition(.openNow, isActive: showOnlyOpen)
            }
        }
    }
    
    private var pointsChip: some View {
        filterChip(isSelected: showOnlyPoints) {
            HStack(spacing: 4) {
                Image(systemName: "star.circle.fill")
                    .font(.system(size: 12))
                    .foregroundStyle(showOnlyPoints ? .white : .yellow)
                Text("Puntos")
            }
        } action: {
            withAnimation(.spring()) {
                showOnlyPoints.toggle()
                updatePosition(.points, isActive: showOnlyPoints)
            }
        }
    }
    
    private var offersChip: some View {
        filterChip(isSelected: showOnlyOffers) {
            HStack(spacing: 4) {
                Image(systemName: "tag.fill")
                    .font(.system(size: 11))
                    .foregroundStyle(showOnlyOffers ? .white : Color.brandGranate)
                Text("Ofertas")
            }
        } action: {
            withAnimation(.spring()) {
                showOnlyOffers.toggle()
                updatePosition(.offers, isActive: showOnlyOffers)
            }
        }
    }
    
    private func updatePosition(_ filter: FilterID, isActive: Bool) {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            if isActive {
                if let index = filterOrder.firstIndex(of: filter) {
                    filterOrder.remove(at: index)
                    filterOrder.insert(filter, at: 0)
                }
            } else {
                filterOrder.sort { a, b in
                    let aActive = isFilterActive(a)
                    let bActive = isFilterActive(b)
                    if aActive != bActive { return aActive }
                    let aInitial = initialOrder.firstIndex(of: a) ?? 0
                    let bInitial = initialOrder.firstIndex(of: b) ?? 0
                    return aInitial < bInitial
                }
            }
        }
    }
    
    private func isFilterActive(_ filter: FilterID) -> Bool {
        switch filter {
        case .sort: return sortOrder != .closest
        case .openNow: return showOnlyOpen
        case .points: return showOnlyPoints
        case .offers: return showOnlyOffers
        }
    }
    
    @ViewBuilder
    private func filterChip(isSelected: Bool = false, @ViewBuilder content: () -> some View, action: @escaping () -> Void = {}) -> some View {
        Button(action: action) {
            content()
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundStyle(isSelected ? .white : .primary)
                .padding(.horizontal, 16)
                .frame(height: 38)
                .background(isSelected ? Color.brandGranate : Color.primary.opacity(0.06))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}
