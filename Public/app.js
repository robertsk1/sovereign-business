// =========================================
// SOVEREIGN JAVASCRIPT ENGINE
// Handles Data Fetching & UI Filtering
// =========================================

let globalData = [];

// 1. Fetch the CSV data when the page loads
document.addEventListener('DOMContentLoaded', () => {
    fetch('leads_pipeline.csv')
        .then(response => {
            if (!response.ok) throw new Error("CSV not found");
            return response.text();
        })
        .then(text => {
            const rows = text.split('\n').filter(row => row.trim() !== '');
            globalData = rows.map(row => {
                const cols = row.split('|');
                return { 
                    name: cols[0] || 'N/A', 
                    url: cols[1] || '#', 
                    email: cols[2] || '', 
                    score: cols[3] || '0', 
                    status: cols[4] || 'Unknown', 
                    issues: cols[5] || 'None' 
                };
            });
            renderTable(globalData);
        })
        .catch(err => console.log("Awaiting first lead generation run...", err));
});

// 2. Build the HTML Table
function renderTable(data) {
    const tbody = document.getElementById('dataGrid');
    if (!tbody) return; // Skip if we aren't on the dashboard page
    
    tbody.innerHTML = ''; 

    data.forEach(item => {
        const statusClass = item.status.includes('Hot') ? 'status-hot' : 'status-cold';
        const row = `<tr>
            <td><strong>${item.name}</strong><br><small><a href="${item.url}" target="_blank">${item.url}</a></small></td>
            <td>${item.score}/100</td>
            <td style="font-weight:bold;" class="${statusClass}">${item.status}</td>
            <td>${item.issues}</td>
            <td><a href="mailto:${item.email}" class="btn" style="padding: 5px 10px; font-size: 0.8rem;">Email</a></td>
        </tr>`;
        tbody.innerHTML += row;
    });
}

// 3. Search & Filter Logic
function filterData() {
    const query = document.getElementById('searchInput')?.value.toLowerCase() || '';
    const category = document.getElementById('categoryFilter')?.value || 'All';

    const filtered = globalData.filter(item => {
        const matchesSearch = item.name.toLowerCase().includes(query) || 
                              item.url.toLowerCase().includes(query) || 
                              item.issues.toLowerCase().includes(query);
        const matchesCategory = category === 'All' || item.status.includes(category);
        
        return matchesSearch && matchesCategory;
    });

    renderTable(filtered);
}

// 4. Attach Listeners to the UI
document.getElementById('searchInput')?.addEventListener('input', filterData);
document.getElementById('categoryFilter')?.addEventListener('change', filterData);